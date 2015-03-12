//
//  CCServerEventListAddedConsumer.m
//  Linotte
//
//  Created by stant on 20/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCServerEventListAddedConsumer.h"

#import "CCLinotteCoreDataStack.h"
#import "CCModelChangeMonitor.h"
#import "CCLinotteEngineCoordinator.h"
#import "CCLinotteAuthenticationManager.h"
#import "CCLinotteAPI.h"

#import "CCList.h"

@implementation CCServerEventListAddedConsumer
{
    NSArray *_events;

    NSURLSessionTask *_currentConnection;
}

@dynamic event;

- (CCServerEventEvent)event
{
    return CCServerEventListAdded;
}

- (BOOL)hasEventsForList:(CCList *)list
{
    _events = [CCServerEvent eventsWithEventType:[self event] list:list];
    return [_events count] != 0;
}

- (void)triggerWithList:(CCList *)list completionBlock:(void(^)(BOOL goOnSyncing, BOOL error))completionBlock
{
    NSArray *eventIds = [_events valueForKeyPath:@"@unionOfObjects.eventId"];
    _currentConnection = [CCLEC.linotteAPI fetchListsForEventIds:eventIds success:^(NSArray *listsDicts) {
        _currentConnection = nil;
        
        NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
        NSArray *lists = [CCList insertInManagedObjectContext:managedObjectContext fromLinotteAPIDictArray:listsDicts];
        
        [CCServerEvent deleteEvents:_events];
        _events = nil;
        
        for (CCList *list in lists) {
            list.hasNewValue = YES;
        }
        
        [[CCLinotteCoreDataStack sharedInstance] saveContext];
        
        [[CCModelChangeMonitor sharedInstance] listsDidAdd:lists send:NO];
        
        completionBlock(YES, NO);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        _currentConnection = nil;
        completionBlock(NO, YES);
    }];
}

@end
