//
//  CCServerEventListUpdateConsumer.m
//  Linotte
//
//  Created by stant on 12/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCServerEventListUpdatedConsumer.h"

#import "CCLinotteAPI.h"
#import "CCModelChangeMonitor.h"
#import "CCCoreDataStack.h"

#import "CCServerEvent.h"

#import "CCList.h"

@implementation CCServerEventListUpdatedConsumer
{
    NSArray *_events;
    
    CCList *_currentList;
    NSURLSessionTask *_currentConnection;
}

@dynamic event;

- (CCServerEventEvent)event
{
    return CCServerEventListUpdated;
}

- (BOOL)hasEventsForList:(CCList *)list
{
    _events = [CCServerEvent eventsWithEventType:[self event] list:list];
    return [_events count] != 0;
}

- (void)triggerWithList:(CCList *)list completionBlock:(void(^)(BOOL goOnSyncing, BOOL error))completionBlock
{
    _currentList = list;
    _currentConnection = [[CCLinotteAPI sharedInstance] fetchCompleteListInfos:list.identifier completionBlock:^(BOOL success, NSDictionary *listInfo) {
        
        _currentList = nil;
        _currentConnection = nil;
        if (success == NO) {
            completionBlock(NO, YES);
            return;
        }
        
        NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
        [CCList insertOrUpdateInManagedObjectContext:managedObjectContext fromLinotteAPIDict:listInfo];
        
        CCLog(@"Updating list %@", list.identifier);

        [CCServerEvent deleteEvents:_events];
        _events = nil;

        [[CCCoreDataStack sharedInstance] saveContext];
        [[CCModelChangeMonitor sharedInstance] listsDidUpdate:@[list] send:NO];
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
