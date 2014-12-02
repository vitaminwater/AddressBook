//
//  CCServerEventAddressMetaAddedConsumer.m
//  Linotte
//
//  Created by stant on 12/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCServerEventAddressMetaAddedConsumer.h"

#import "CCLinotteAPI.h"
#import "CCModelChangeMonitor.h"
#import "CCCoreDataStack.h"

#import "CCServerEvent.h"
#import "CCAddressMeta.h"
#import "CCAddress.h"
#import "CCList.h"

@implementation CCServerEventAddressMetaAddedConsumer
{
    NSArray *_events;
    
    CCList *_currentList;
    NSURLSessionTask *_currentConnection;
}

@dynamic event;

- (CCServerEventEvent)event
{
    return CCServerEventAddressMetaAdded;
}

- (BOOL)hasEventsForList:(CCList *)list
{
    _events = [CCServerEvent eventsWithEventType:[self event] list:list];
    return [_events count] != 0;
}

- (void)triggerWithList:(CCList *)list completionBlock:(void(^)(BOOL goOnSyncing, BOOL error))completionBlock
{
    NSArray *eventIds = [_events valueForKeyPath:@"@unionOfObjects.eventId"];
    _currentList = list;
    _currentConnection = [[CCLinotteAPI sharedInstance] fetchAddressMetasForEventIds:eventIds completionBlock:^(BOOL success, NSArray *addressMetaDicts) {
        
        _currentList = nil;
        _currentConnection = nil;
        if (success == NO) {
            completionBlock(NO, YES);
            return;
        }
        
        NSError *error = nil;
        NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
        NSArray *addressMetas = [CCAddressMeta insertInManagedObjectContext:managedObjectContext fromLinotteAPIDictArray:addressMetaDicts];
        
        NSArray *addressesIdentifiersToLoad = [_events valueForKeyPath:@"@unionOfObjects.objectIdentifier2"];
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY lists = %@ and identifier in %@", list, addressesIdentifiersToLoad];
        [fetchRequest setPredicate:predicate];
        NSArray *addresses = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if (error != nil) {
            CCLog(@"%@", error);
            completionBlock(NO, NO);
            return;
        }
        
        NSArray *metasIdentifiersFromEvents = [_events valueForKeyPath:@"@unionOfObjects.objectIdentifier"];
        NSArray *addressesIdentifiersLoaded = [addresses valueForKeyPath:@"@unionOfObjects.identifier"];
        
        for (CCAddressMeta *addressMeta in addressMetas) {
            NSUInteger metaIndexFromEvent = [metasIdentifiersFromEvents indexOfObject:addressMeta.identifier];
            
            if (metaIndexFromEvent == NSNotFound)
                continue;
            
            NSString *addressIdentifier = ((CCServerEvent *)_events[metaIndexFromEvent]).objectIdentifier2;
            NSUInteger addressIndex = [addressesIdentifiersLoaded indexOfObject:addressIdentifier];
            
            if (addressIndex == NSNotFound)
                continue;

            CCAddress *address = addresses[addressIndex];
            [address addMetasObject:addressMeta];
        }
        
        [CCServerEvent deleteEvents:_events];
        _events = nil;

        [[CCCoreDataStack sharedInstance] saveContext];
        [[CCModelChangeMonitor sharedInstance] addressMetasAdd:addressMetas];
        completionBlock(YES, NO);
    }];
}

#pragma mark - CCModelChangeMonitorDelegate

- (void)listWillRemove:(CCList *)list send:(BOOL)send
{
    if (_currentList == list)
        [_currentConnection cancel];
}

@end
