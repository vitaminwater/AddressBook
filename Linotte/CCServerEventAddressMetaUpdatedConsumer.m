//
//  CCServerEventAddressMetaUpdatedConsumer.m
//  Linotte
//
//  Created by stant on 12/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCServerEventAddressMetaUpdatedConsumer.h"

#import "CCLinotteEngineCoordinator.h"
#import "CCLinotteAPI.h"
#import "CCLinotteCoreDataStack.h"
#import "CCModelChangeMonitor.h"

#import "CCServerEvent.h"
#import "CCAddressMeta.h"

@implementation CCServerEventAddressMetaUpdatedConsumer
{
    NSArray *_events;
    
    CCList *_currentList;
    NSURLSessionTask *_currentConnection;
}

@dynamic event;

- (CCServerEventEvent)event
{
    return CCServerEventAddressMetaUpdated;
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
    _currentConnection = [CCLEC.linotteAPI fetchAddressMetasForEventIds:eventIds success:^(NSArray *addressMetaDicts) {
        _currentList = nil;
        _currentConnection = nil;
        
        NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
        NSArray *addressMetas = [CCAddressMeta insertOrUpdateInManagedObjectContext:managedObjectContext fromLinotteAPIDictArray:addressMetaDicts list:list];
        
        [CCServerEvent deleteEvents:_events];
        _events = nil;
        
        [[CCLinotteCoreDataStack sharedInstance] saveContext];
        [[CCModelChangeMonitor sharedInstance] addressMetasUpdate:addressMetas];
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
