//
//  CCServerEventUserDataUpdatedConsumer.m
//  Linotte
//
//  Created by stant on 12/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCServerEventAddressUserDataUpdatedConsumer.h"

#import "CCLinotteEngineCoordinator.h"
#import "CCLinotteAPI.h"
#import "CCModelChangeMonitor.h"
#import "CCLinotteCoreDataStack.h"

#import "CCServerEvent.h"
#import "CCAddress.h"

@implementation CCServerEventAddressUserDataUpdatedConsumer
{
    NSArray *_events;
    
    CCList *_currentList;
    NSURLSessionTask *_currentConnection;
}

@dynamic event;

- (CCServerEventEvent)event
{
    return CCServerEventAddressUserDataUpdated;
}

- (BOOL)hasEventsForList:(CCList *)list
{
    _events = [CCServerEvent eventsWithEventType:[self event] list:list];
    return [_events count] != 0;
}

- (void)triggerWithList:(CCList *)list completionBlock:(CCSynchronizationCompletionBlock)completionBlock
{
    NSArray *eventIds = [_events valueForKeyPath:@"@unionOfObjects.eventId"];
    _currentList = list;
    _currentConnection = [CCLEC.linotteAPI fetchAddressUserDataForEventIds:eventIds success:^(NSArray *userDatas) {
        _currentList = nil;
        _currentConnection = nil;
        
        NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
        
        NSArray *addresses = [CCAddress updateUserDatasInManagedObjectContext:managedObjectContext fromLinotteAPIDictArray:userDatas list:list shittyBlock:^(NSArray *addresses) {
            [[CCModelChangeMonitor sharedInstance] addressesWillUpdateUserData:addresses send:NO];
        }];
        
        [CCServerEvent deleteEvents:_events];
        _events = nil;
        
        [[CCLinotteCoreDataStack sharedInstance] saveContext];
        [[CCModelChangeMonitor sharedInstance] addressesDidUpdateUserData:addresses send:NO];
        completionBlock(YES, NO);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        _currentList = nil;
        _currentConnection = nil;
        
        completionBlock(NO, YES);
    }];
}

#pragma mark - CCModelChangeMonitorDelegate

- (void)listWillRemove:(CCList *)list send:(BOOL)send
{
    if (_currentList == list)
        [_currentConnection cancel];
}

@end
