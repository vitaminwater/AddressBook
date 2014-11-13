//
//  CCServerEventAddressMovedFromListConsumer.m
//  Linotte
//
//  Created by stant on 12/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCServerEventAddressMovedFromListConsumer.h"

#import "CCCoreDataStack.h"
#import "CCModelChangeMonitor.h"

#import "CCServerEventConsumerUtils.h"

#import "CCList.h"
#import "CCAddress.h"

@implementation CCServerEventAddressMovedFromListConsumer
{
    NSArray *_events;
}

- (BOOL)hasEventsForList:(CCList *)list
{
    _events = [CCServerEventConsumerUtils eventsWithEventType:CCServerEventAddressMovedFromList list:list];
    return [_events count] != 0;
}

- (void)triggerWithList:(CCList *)list completionBlock:(void(^)())completionBlock
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    NSArray *identifiers = [_events valueForKeyPath:@"@distrinctUnionOfObejcts.object_identifier"];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier in %@", identifiers];
    [fetchRequest setPredicate:predicate];
    NSArray *addresses = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    
    NSMutableArray *addressesToDelete = [@[] mutableCopy];
    for (CCAddress *address in addresses) {
        if ([address.lists count] == 1)
            [addressesToDelete addObject:address];
    }
    
    [[CCModelChangeMonitor sharedInstance] addresses:addresses willMoveFromList:list send:NO];
    [list removeAddresses:[NSSet setWithArray:addresses]];
    [[CCModelChangeMonitor sharedInstance] addresses:addresses didMoveFromList:list send:NO];
    
    for (CCAddress *address in addressesToDelete) {
        [managedObjectContext deleteObject:address];
    }
    
    [[CCCoreDataStack sharedInstance] saveContext];
}

@end
