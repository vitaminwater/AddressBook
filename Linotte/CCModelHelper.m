//
//  CCModelHelper.m
//  Linotte
//
//  Created by stant on 23/10/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCModelHelper.h"

#import <Mixpanel/Mixpanel.h>

#import "CCModelChangeMonitor.h"
#import "CCCoreDataStack.h"

#import "CCList.h"
#import "CCAddress.h"

@implementation CCModelHelper

/**
 * Move all these to mogenerator's classes ?
 */

+ (void)deleteAddress:(CCAddress *)address
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    [[Mixpanel sharedInstance] track:@"Address deleted" properties:@{@"name": address.name ?: @"",
                                                                     @"address": address.address ?: @"",
                                                                     @"identifier": address.identifier ?: @"NEW"}];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"owned = %@", @YES];
    NSSet *lists = [address.lists filteredSetUsingPredicate:predicate];
    for (CCList *list in lists) {
        [[CCModelChangeMonitor sharedInstance] addresses:@[address] willMoveFromList:list send:YES];
        [address removeListsObject:list];
        [[CCCoreDataStack sharedInstance] saveContext];
        [[CCModelChangeMonitor sharedInstance] addresses:@[address] didMoveFromList:list send:YES];
    }
    
    if ([address.lists count] == 0)
        [managedObjectContext deleteObject:address];
    
    [[CCCoreDataStack sharedInstance] saveContext];
}

+ (void)deleteList:(CCList *)list
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    NSString *identifier = list.identifier;

    [[Mixpanel sharedInstance] track:@"List deleted" properties:@{@"name": list.name,
                                                                     @"identifier": list.identifier ?: @"NEW"}];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY lists = %@ AND lists.@count = 1", list];
    
    [fetchRequest setPredicate:predicate];
    NSArray *addressesToDelete = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    
    [[CCModelChangeMonitor sharedInstance] listWillRemove:list send:YES];
    [managedObjectContext deleteObject:list];
    [[CCCoreDataStack sharedInstance] saveContext];
    [[CCModelChangeMonitor sharedInstance] listDidRemove:identifier send:YES];
    
    for (CCAddress *address in addressesToDelete) {
        [managedObjectContext deleteObject:address];
    }
    [[CCCoreDataStack sharedInstance] saveContext];
}

+ (CCList *)defaultList
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCList entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isdefault = %@", @YES];
    fetchRequest.predicate = predicate;
    NSArray *lists = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    
    if ([lists count])
        return [lists firstObject];
    
    CCList *list = [CCList insertInManagedObjectContext:managedObjectContext];
    list.name = NSLocalizedString(@"DEFAULT_LIST_NAME", @"");
    list.isdefault = @YES;
    [[CCCoreDataStack sharedInstance] saveContext];
    [[CCModelChangeMonitor sharedInstance] listDidAdd:list send:YES];
    
    return list;
}

@end