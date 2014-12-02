//
//  CCServerEventListAddedConsumer.m
//  Linotte
//
//  Created by stant on 20/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCServerEventListAddedConsumer.h"

#import "CCCoreDataStack.h"
#import "CCModelChangeMonitor.h"

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
    _currentConnection = [[CCLinotteAPI sharedInstance] fetchListsForEventIds:eventIds completionBlock:^(BOOL success, NSArray *listsDicts) {
        
        _currentConnection = nil;
        if (success == NO) {
            completionBlock(NO, YES);
            return;
        }
        
        NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
        NSArray *lists = [CCList insertInManagedObjectContext:managedObjectContext fromLinotteAPIDictArray:listsDicts];
        
        for (CCList *list in lists) {
            list.ownedValue = [list.authorIdentifier isEqualToString:[CCLinotteAPI sharedInstance].identifier];
        }
        
        [CCServerEvent deleteEvents:_events];
        _events = nil;
        
        [[CCCoreDataStack sharedInstance] saveContext];
        
        [[CCModelChangeMonitor sharedInstance] listsDidAdd:lists send:NO];
        
        completionBlock(YES, NO);
    }];
}

@end
