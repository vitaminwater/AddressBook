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
    NSString *identifier = address.identifier;
    
    NSString *mixidentifier = address.identifier ?: @"NEW";
    [[Mixpanel sharedInstance] track:@"Address deleted" properties:@{@"name": address.name ?: @"",
                                                                     @"address": address.address ?: @"",
                                                                     @"identifier": mixidentifier}];
    
    [[CCModelChangeMonitor sharedInstance] addressWillRemove:address];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"owned = %@", @YES];
    NSSet *lists = [address.lists filteredSetUsingPredicate:predicate];
    [address removeLists:lists];
    
    if ([address.lists count] == 0)
        [managedObjectContext deleteObject:address];
    
    [[CCCoreDataStack sharedInstance] saveContext];
    
    [[CCModelChangeMonitor sharedInstance] addressDidRemove:identifier];
}

+ (void)deleteList:(CCList *)list
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    NSString *identifier = list.identifier;

    NSString *mixidentifier = list.identifier ?: @"NEW";
    [[Mixpanel sharedInstance] track:@"List deleted" properties:@{@"name": list.name,
                                                                     @"identifier": mixidentifier}];
    
    [[CCModelChangeMonitor sharedInstance] listWillRemove:list];
    
    [managedObjectContext deleteObject:list];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lists.@count = 0"];
    
    [fetchRequest setPredicate:predicate];
    NSArray *addresses = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    
    for (CCAddress *address in addresses) {
        [managedObjectContext deleteObject:address];
    }
    
    [[CCCoreDataStack sharedInstance] saveContext];
    
    [[CCModelChangeMonitor sharedInstance] listDidRemove:identifier];
}

+ (CCList *)defaultList
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCList entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isdefault = %@", @(YES)];
    fetchRequest.predicate = predicate;
    NSArray *lists = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    
    if ([lists count])
        return [lists firstObject];
    
    CCList *list = [CCList insertInManagedObjectContext:managedObjectContext];
    list.name = NSLocalizedString(@"DEFAULT_LIST_NAME", @"");
    list.isdefault = @(YES);
    [[CCCoreDataStack sharedInstance] saveContext];
    [[CCModelChangeMonitor sharedInstance] listDidAdd:list];
    
    return list;
}

@end
