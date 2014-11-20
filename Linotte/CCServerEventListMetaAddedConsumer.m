//
//  CCServerEventListMetaAdded.m
//  Linotte
//
//  Created by stant on 12/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCServerEventListMetaAddedConsumer.h"

#import "CCLinotteAPI.h"
#import "CCModelChangeMonitor.h"
#import "CCCoreDataStack.h"

#import "CCServerEvent.h"
#import "CCListMeta.h"
#import "CCList.h"

@implementation CCServerEventListMetaAddedConsumer
{
    NSArray *_events;
    
    CCList *_currentList;
    NSURLSessionTask *_currentConnection;
}

@dynamic event;

- (CCServerEventEvent)event
{
    return CCServerEventListMetaAdded;
}

- (BOOL)hasEventsForList:(CCList *)list
{
    _events = [CCServerEvent eventsWithEventType:[self event] list:list];
    return [_events count] != 0;
}

- (void)triggerWithList:(CCList *)list completionBlock:(void(^)(BOOL goOnSyncing))completionBlock
{
    NSArray *eventIds = [_events valueForKeyPath:@"@unionOfObjects.eventId"];
    _currentList = list;
    _currentConnection = [[CCLinotteAPI sharedInstance] fetchListMetasForEventIds:eventIds completionBlock:^(BOOL success, NSArray *addressMetaDicts) {
        
        _currentList = nil;
        _currentConnection = nil;
        if (success == NO) {
            completionBlock(NO);
            return;
        }
        
        NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
        NSArray *listMetas = [CCListMeta insertInManagedObjectContext:managedObjectContext fromLinotteAPIDictArray:addressMetaDicts];
        
        CCLog(@"Adding %lu metas for list %@", [listMetas count], list.identifier);

        [list addMetas:[NSSet setWithArray:listMetas]];
        
        [CCServerEvent deleteEvents:_events];
        _events = nil;

        [[CCCoreDataStack sharedInstance] saveContext];
        [[CCModelChangeMonitor sharedInstance] addressMetasAdd:listMetas];
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
