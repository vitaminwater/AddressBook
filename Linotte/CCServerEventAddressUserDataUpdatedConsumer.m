//
//  CCServerEventUserDataUpdatedConsumer.m
//  Linotte
//
//  Created by stant on 12/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCServerEventAddressUserDataUpdatedConsumer.h"

#import "CCLinotteAPI.h"
#import "CCModelChangeMonitor.h"
#import "CCCoreDataStack.h"

#import "CCServerEvent.h"
#import "CCAddress.h"

@implementation CCServerEventAddressUserDataUpdatedConsumer
{
    NSArray *_events;
    
    CCList *_currentList;
    NSURLSessionTask *_currentConnection;
}

- (BOOL)hasEventsForList:(CCList *)list
{
    _events = [CCServerEvent eventsWithEventType:CCServerEventAddressUserDataUpdated list:list];
    return [_events count] != 0;
}

- (void)triggerWithList:(CCList *)list completionBlock:(void(^)(BOOL goOnSyncing))completionBlock
{
    NSArray *eventIds = [_events valueForKeyPath:@"@unionOfObjects.eventId"];
    _currentList = list;
    _currentConnection = [[CCLinotteAPI sharedInstance] fetchAddressUserDataForEventIds:eventIds completionBlock:^(BOOL success, NSArray *userDatas) {
        
        _currentList = nil;
        _currentConnection = nil;
        if (success == NO) {
            completionBlock(NO);
            return;
        }
        
        NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
        
        NSArray *addresses = [CCAddress updateUserDatasInManagedObjectContext:managedObjectContext fromLinotteAPIDictArray:userDatas list:list];
        
        [CCServerEvent deleteEvents:_events];
        _events = nil;

        [[CCCoreDataStack sharedInstance] saveContext];
        [[CCModelChangeMonitor sharedInstance] addressesDidUpdateUserData:addresses send:NO];
        completionBlock(YES);
    }];
}

#pragma mark - CCModelChangeMonitorDelegate

- (void)listWillRemove:(CCList *)list send:(BOOL)send
{
    if (_currentList == list)
        [_currentConnection cancel];
}

@end
