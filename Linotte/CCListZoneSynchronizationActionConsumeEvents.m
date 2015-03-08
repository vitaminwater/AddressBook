//
//  CCListZoneSynchronizationActionConsumeEvents.m
//  Linotte
//
//  Created by stant on 17/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListZoneSynchronizationActionConsumeEvents.h"

#import "CCLinotteCoreDataStack.h"

#import "CCLinotteEngineCoordinator.h"
#import "CCLinotteAPI.h"

#import "CCServerEventAddressAddedToListConsumer.h"
#import "CCServerEventAddressMovedFromListConsumer.h"
#import "CCServerEventAddressUpdatedConsumer.h"
#import "CCServerEventAddressUserDataUpdatedConsumer.h"
#import "CCServerEventAddressMetaAddedConsumer.h"
#import "CCServerEventAddressMetaUpdatedConsumer.h"
#import "CCServerEventAddressMetaDeletedConsumer.h"

#import "CCList.h"
#import "CCListZone.h"
#import "CCServerEvent.h"

#if defined(CCSHORT_REFRESH)

#define kCCShortRefreshSpan -(20)

#endif

/**
 * Network block factory
 */

void fetchListEventsProcess(CCList *list, CCListZone *listZone, NSArray *eventsDicts) {
    listZone.lastUpdate = [NSDate date];
    if ([eventsDicts count] == 0) {
        if (listZone.needsMerge != nil) {
            listZone.readyToMergeValue = YES;
        }
        [listZone updateNextRefreshDate:YES];
        [[CCLinotteCoreDataStack sharedInstance] saveContext];
        return;
    }
    [listZone updateNextRefreshDate:NO];
    
    CCLog(@"%lu events received", [eventsDicts count]);
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    NSDate *lastEventDate = nil;
    for (NSDictionary *eventDict in eventsDicts) {
        CCServerEvent *serverEvent = [CCServerEvent insertInManagedObjectContext:managedObjectContext fromLinotteAPIDict:eventDict];
        [list addServerEventsObject:serverEvent];
        lastEventDate = serverEvent.date;
    }
    listZone.lastEventDate = lastEventDate;
    [[CCLinotteCoreDataStack sharedInstance] saveContext];
}

/**
 * CCListZoneSynchronizationActionConsumeEvents
 */

@implementation CCListZoneSynchronizationActionConsumeEvents
{
    CCList *_currentList;
    NSURLSessionTask *_currentConnection;
    
    NSArray *_consumers;
    NSArray *_events;
}

- (instancetype)init
{
    self = [super initWithProvider:self];
    if (self) {
        _consumers = @[
                       [CCServerEventAddressAddedToListConsumer new],
                       [CCServerEventAddressMovedFromListConsumer new],
                       [CCServerEventAddressUpdatedConsumer new],
                       [CCServerEventAddressUserDataUpdatedConsumer new],
                       [CCServerEventAddressMetaAddedConsumer new],
                       [CCServerEventAddressMetaUpdatedConsumer new],
                       [CCServerEventAddressMetaDeletedConsumer new],
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
#if defined(CCSHORT_REFRESH)
        NSDate *minDate = [[NSDate date] dateByAddingTimeInterval:kCCShortRefreshSpan];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier != nil and subquery(zones, $zone, $zone.firstFetch = %@ and $zone.lastUpdate < %@).@count > 0", @(NO), minDate];
#else
        NSString *predicateFormat = [NSString stringWithFormat:@"identifier != nil and subquery(zones, $zone, $zone.firstFetch = %%@ and $zone.%@ < %%@).@count > 0", kCCFullSync ? @"shortNextRefreshDate" : @"longNextRefreshDate"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat, @(NO), [NSDate date]];
#endif
        [fetchRequest setPredicate:predicate];
        
        lists = [[managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
        
        if (error != nil) {
            CCLog(@"%@", error);
            return nil;
        }
    }
    
    if ([lists count] == 0)
        return nil;
    
    NSSortDescriptor *lastUpdateSortDesciptor = [NSSortDescriptor sortDescriptorWithKey:@"zones.@min.lastUpdate" ascending:YES];
    [lists sortUsingDescriptors:@[lastUpdateSortDesciptor]];
    
    CCList *list = [lists firstObject];
    
    return list;
}

- (NSArray *)eventsList
{
    return _events;
}

- (void)fetchServerEventsWithList:(CCList *)list completionBlock:(CCSynchronizationCompletionBlock)completionBlock
{
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCListZone entityName]];
#if defined(CCSHORT_REFRESH)
    NSDate *minDate = [[NSDate date] dateByAddingTimeInterval:kCCShortRefreshSpan];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"list = %@ and firstFetch = %@ and lastUpdate < %@", list, @(NO), minDate];
#else
    NSString *predicateFormat = [NSString stringWithFormat:@"list = %%@ and firstFetch = %%@ and %@ < %%@", kCCFullSync ? @"shortNextRefreshDate" : @"longNextRefreshDate"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat, list, @(NO), [NSDate date]];
#endif
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastUpdate" ascending:YES];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    fetchRequest.fetchLimit = 1;
    
    NSError *error = nil;
    NSArray *listZones = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error != nil) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            completionBlock(NO, NO);
        });
        CCLog(@"%@", error);
        return;
    }
    
    if ([listZones count] == 0) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            completionBlock(NO, NO);
        });
        return;
    }
    
    CCListZone *listZone = [listZones firstObject];
    CCLog(@"Event fetch for zone: %@", listZone.geohash);
    _currentList = list;
    _currentConnection = [CCLEC.linotteAPI fetchListEvents:list.identifier geohash:listZone.geohash lastDate:listZone.lastEventDate success:^(NSArray *eventsDicts) {
        _currentList = nil;
        _currentConnection = nil;
        
        fetchListEventsProcess(list, listZone, eventsDicts);
        
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
