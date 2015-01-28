//
//  CCListSynchronizationActionConsumeEvents.m
//  Linotte
//
//  Created by stant on 17/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListSynchronizationActionConsumeEvents.h"

#import "CCLinotteCoreDataStack.h"
#import "CCLinotteEngineCoordinator.h"
#import "CCLinotteAPI.h"

#import "CCServerEventListUpdatedConsumer.h"
#import "CCServerEventListUserDataUpdatedConsumer.h"
#import "CCServerEventListMetaAddedConsumer.h"
#import "CCServerEventListMetaUpdatedConsumer.h"
#import "CCServerEventListMetaDeletedConsumer.h"

#import "CCList.h"
#import "CCListZone.h"
#import "CCServerEvent.h"

#define kCCDateIntervalDifference -(12 * 60 * 60)

@implementation CCListSynchronizationActionConsumeEvents
{
    CCList *_currentList;
    NSURLSessionTask *_currentConnection;
    BOOL _multipleWaitingLists;
    
    NSArray *_consumers;
    NSArray *_events;
}

- (instancetype)init
{
    self = [super initWithProvider:self];
    if (self) {
        _consumers = @[
                       [CCServerEventListUpdatedConsumer new],
                       [CCServerEventListUserDataUpdatedConsumer new],
                       [CCServerEventListMetaAddedConsumer new],
                       [CCServerEventListMetaUpdatedConsumer new],
                       [CCServerEventListMetaDeletedConsumer new],
                       ];
        _events = [_consumers valueForKeyPath:@"@unionOfObjects.event"];
    }
    return self;
}

- (NSArray *)consumers
{
    return _consumers;
}

- (CCList *)findNextListToProcess
{
    
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCList entityName]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier != nil and SUBQUERY(serverEvents, $serverEvent, $serverEvent.event in %@).@count > 0", [self eventsList]];
    [fetchRequest setPredicate:predicate];
    
    NSMutableArray *lists = [[managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    if (error != nil) {
        CCLog(@"%@", error);
        return nil;
    }
    
    if ([lists count] == 0) {
        NSDate *minDate = [[NSDate date] dateByAddingTimeInterval:kCCDateIntervalDifference];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier != nil and lastUpdate < %@", minDate];
        [fetchRequest setPredicate:predicate];
        
        lists = [[managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
        
        if (error != nil) {
            CCLog(@"%@", error);
            return nil;
        }
    }
    
    _multipleWaitingLists = [lists count] > 1;
    
    if ([lists count] == 0)
        return nil;
    
    NSSortDescriptor *lastUpdateSortDesciptor = [NSSortDescriptor sortDescriptorWithKey:@"lastUpdate" ascending:YES];
    [lists sortUsingDescriptors:@[lastUpdateSortDesciptor]];
    
    CCList *list = [lists firstObject];

    return list;
}

- (NSArray *)eventsList
{
    return _events;
}

- (void)fetchServerEventsWithList:(CCList *)list completionBlock:(void(^)(BOOL goOnSyncing, BOOL error))completionBlock
{
    _currentList = list;
    BOOL multipleWaitingLists = _multipleWaitingLists;
    _multipleWaitingLists = NO;
    if (list.lastEventDate == nil) {
        _currentConnection = [CCLEC.linotteAPI fetchListLastEventDate:list.identifier success:^(NSDate *lastEventDate) {
            _currentList = nil;
            _currentConnection = nil;
            
            list.lastEventDate = lastEventDate;
            [[CCLinotteCoreDataStack sharedInstance] saveContext];
            completionBlock(YES, NO);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            _currentList = nil;
            _currentConnection = nil;
            
            completionBlock(NO, YES);
        }];
        return;
    }
    
    _currentConnection = [CCLEC.linotteAPI fetchListEvents:list.identifier lastDate:list.lastEventDate success:^(NSArray *eventsDicts) {
        _currentList = nil;
        _currentConnection = nil;
        
        list.lastUpdate = [NSDate date];
        
        if ([eventsDicts count] == 0) {
            [[CCLinotteCoreDataStack sharedInstance] saveContext];
            completionBlock(multipleWaitingLists, NO);
            return;
        }
        
        CCLog(@"%lu events received", [eventsDicts count]);
        NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
        NSDate *lastEventDate = nil;
        for (NSDictionary *eventDict in eventsDicts) {
            CCServerEvent *serverEvent = [CCServerEvent insertInManagedObjectContext:managedObjectContext fromLinotteAPIDict:eventDict];
            [list addServerEventsObject:serverEvent];
            lastEventDate = serverEvent.date;
        }
        list.lastEventDate = lastEventDate;
        [[CCLinotteCoreDataStack sharedInstance] saveContext];
        completionBlock(YES, NO);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        _currentList = nil;
        _currentConnection = nil;
        
        completionBlock(NO, YES);
    }];
}

- (BOOL)requiresList
{
    return YES;
}

#pragma mark - CCModelChangeMonitorDelegate

- (void)listWillRemove:(CCList *)list send:(BOOL)send
{
    if (_currentList == list)
        [_currentConnection cancel];
}

@end
