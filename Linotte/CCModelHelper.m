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
#import "CCLinotteCoreDataStack.h"

#import "CCList.h"
#import "CCAddress.h"

@implementation CCModelHelper

/**
 * Move all these to mogenerator's classes ?
 */

+ (void)deleteAddress:(CCAddress *)address
{
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    
    @try {
        [[Mixpanel sharedInstance] track:@"Address deleted" properties:@{@"name": address.name ?: @"",
                                                                         @"address": address.address ?: @"",
                                                                         @"identifier": address.identifier ?: @"NEW"}];
    }
    @catch(NSException *e) {
        CCLog(@"%@", e);
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"owned = %@", @YES];
    NSSet *lists = [address.lists filteredSetUsingPredicate:predicate];
    for (CCList *list in lists) {
        [[CCModelChangeMonitor sharedInstance] addresses:@[address] willMoveFromList:list send:YES];
        [address removeListsObject:list];
        [[CCLinotteCoreDataStack sharedInstance] saveContext];
        [[CCModelChangeMonitor sharedInstance] addresses:@[address] didMoveFromList:list send:YES];
    }
    
    if ([address.lists count] == 0)
        [managedObjectContext deleteObject:address];
    
    [[CCLinotteCoreDataStack sharedInstance] saveContext];
}

+ (void)deleteList:(CCList *)list
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    NSString *identifier = list.identifier;

    @try {
        [[Mixpanel sharedInstance] track:@"List deleted" properties:@{@"name": list.name,
                                                                     @"identifier": list.identifier ?: @"NEW"}];
    }
    @catch(NSException *e) {
        CCLog(@"%@", e);
    }
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY lists = %@ AND lists.@count = 1", list];
    
    [fetchRequest setPredicate:predicate];
    NSArray *addressesToDelete = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        CCLog(@"%@", error);
        addressesToDelete = @[];
    }
    
    [[CCModelChangeMonitor sharedInstance] listsWillRemove:@[list] send:YES];
    [managedObjectContext deleteObject:list];
    [[CCLinotteCoreDataStack sharedInstance] saveContext];
    [[CCModelChangeMonitor sharedInstance] listsDidRemove:@[identifier] send:YES];
    
    for (CCAddress *address in addressesToDelete) {
        [managedObjectContext deleteObject:address];
    }
    [[CCLinotteCoreDataStack sharedInstance] saveContext];
}

+ (CCList *)defaultList
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCList entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isdefault = %@", @YES];
    fetchRequest.predicate = predicate;
    NSArray *lists = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        CCLog(@"%@", error);
    }
    
    if ([lists count])
        return [lists firstObject];
    
    CCList *list = [CCList insertInManagedObjectContext:managedObjectContext];
    list.name = NSLocalizedString(@"DEFAULT_LIST_NAME", @"");
    list.isdefault = @YES;
    [[CCLinotteCoreDataStack sharedInstance] saveContext];
    [[CCModelChangeMonitor sharedInstance] listsDidAdd:@[list] send:YES];
    
    return list;
}

@end