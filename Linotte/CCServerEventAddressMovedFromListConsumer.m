//
//  CCServerEventAddressMovedFromListConsumer.m
//  Linotte
//
//  Created by stant on 12/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCServerEventAddressMovedFromListConsumer.h"

#import "CCLinotteCoreDataStack.h"
#import "CCModelChangeMonitor.h"

#import "CCServerEvent.h"

#import "CCList.h"
#import "CCAddress.h"
#import "CCListZone.h"

@implementation CCServerEventAddressMovedFromListConsumer
{
    NSArray *_events;
}

@dynamic event;

- (CCServerEventEvent)event
{
    return CCServerEventAddressMovedFromList;
}

- (BOOL)hasEventsForList:(CCList *)list
{
    _events = [CCServerEvent eventsWithEventType:[self event] list:list];
    return [_events count] != 0;
}

- (void)triggerWithList:(CCList *)list completionBlock:(CCSynchronizationCompletionBlock)completionBlock
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    
    NSArray *identifiers = [_events valueForKeyPath:@"@distinctUnionOfObjects.objectIdentifier"];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier in %@", identifiers];
    [fetchRequest setPredicate:predicate];
    NSArray *addresses = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        CCLog(@"%@", error);
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(NO, NO);
        });
        return;
    }
    
    NSMutableArray *addressesToDelete = [@[] mutableCopy];
    for (CCAddress *address in addresses) {
        if ([address.lists count] == 1) {
            [addressesToDelete addObject:address];
        }
    }
    
    // update concerned zones nAddresses, keep trace of all the geohashes
    NSArray *geohashes = [addressesToDelete valueForKeyPath:@"@distinctUnionOfObjects.geohash"];
    
    [[CCModelChangeMonitor sharedInstance] addresses:addresses willMoveFromList:list send:NO];
    [list removeAddresses:[NSSet setWithArray:addresses]];
    [[CCModelChangeMonitor sharedInstance] addresses:addresses didMoveFromList:list send:NO];
    
    for (CCAddress *address in addressesToDelete) {
        [managedObjectContext deleteObject:address];
    }
    
    [CCServerEvent deleteEvents:_events];
    _events = nil;
    
    [[CCLinotteCoreDataStack sharedInstance] saveContext];
    
    // update concerned zones nAddresses
    [CCListZone updateNAddressesForGeohashes:[NSSet setWithArray:geohashes] list:list inManagedObjectContext:managedObjectContext];
    [[CCLinotteCoreDataStack sharedInstance] saveContext];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        completionBlock(YES, NO);
    });
}

@end
