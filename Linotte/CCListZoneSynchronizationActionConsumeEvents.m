//
//  CCListZoneSynchronizationActionConsumeEvents.m
//  Linotte
//
//  Created by stant on 17/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListZoneSynchronizationActionConsumeEvents.h"

#import "CCCoreDataStack.h"

#import "CCLinotteAPI.h"

#import "CCServerEventListUpdatedConsumer.h"
#import "CCServerEventListMetaAddedConsumer.h"
#import "CCServerEventListMetaUpdatedConsumer.h"
#import "CCServerEventListMetaDeletedConsumer.h"

#import "CCList.h"
#import "CCListZone.h"
#import "CCServerEvent.h"

@implementation CCListZoneSynchronizationActionConsumeEvents
{
    CCList *_currentList;
    NSURLSessionTask *_currentConnection;
}

- (instancetype)init
{
    self = [super initWithProvider:self];
    if (self) {
        
    }
    return self;
}

- (NSArray *)consumers
{
    return @[
             [CCServerEventListUpdatedConsumer new],
             [CCServerEventListMetaAddedConsumer new],
             [CCServerEventListMetaUpdatedConsumer new],
             [CCServerEventListMetaDeletedConsumer new],
             ];
}

- (CCList *)findNextListToProcess
{
    NSDate *minDate = [[NSDate date] dateByAddingTimeInterval:-(12 * 60 * 60)];
    
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCList entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serverEvents.@count > 0 or subquery(zones, $zone, $zone.firstFetch = %@ and $zone.lastUpdate < %@).@count > 0", @NO, minDate];
    [fetchRequest setPredicate:predicate];
    
    NSMutableArray *lists = [[managedObjectContext executeFetchRequest:fetchRequest error:NULL] mutableCopy];
    
    if ([lists count] == 0)
        return nil;
    
    NSSortDescriptor *eventNumberSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"serverEvents.@count" ascending:NO];
    NSSortDescriptor *lastUpdateSortDesciptor = [NSSortDescriptor sortDescriptorWithKey:@"zones.@min.lastUpdate" ascending:YES];
    [lists sortedArrayUsingDescriptors:@[eventNumberSortDescriptor, lastUpdateSortDesciptor]];
    
    CCList *list = [lists firstObject];
    
    if (list == nil)
        return nil;
    
    return list;
}

- (NSArray *)eventsList
{
    return @[@1, @2, @3, @4];
}

- (void)fetchServerEventsWithList:(CCList *)list completionBlock:(void(^)(BOOL goOnSyncing))completionBlock
{
    NSDate *minDate = [[NSDate date] dateByAddingTimeInterval:-(12 * 60 * 60)];
    
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCListZone entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"list = %@ and firstFetch = %@ and lastUpdate < %@", list, @(NO), minDate];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastUpdate" ascending:YES];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    fetchRequest.fetchLimit = 1;
    
    NSError *error = nil;
    NSArray *listZones = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error != nil) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            completionBlock(NO);
        });
        CCLog(@"%@", error);
        return;
    }
    
    if ([listZones count] == 0) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            completionBlock(NO);
        });
        return;
    }
    
    CCListZone *listZone = [listZones firstObject];
    CCLog(@"Event fetch for zone: %@", listZone.geohash);
    _currentList = list;
    _currentConnection = [[CCLinotteAPI sharedInstance] fetchListEvents:list.identifier geohash:listZone.geohash lastDate:listZone.lastEventDate completionBlock:^(BOOL success, NSArray *eventsDicts) {
        
        _currentList = nil;
        _currentConnection = nil;
        if (success == NO) {
            completionBlock(NO);
            return;
        }
        
        listZone.lastUpdate = [NSDate date];
        if ([eventsDicts count] == 0) {
            [[CCCoreDataStack sharedInstance] saveContext];
            completionBlock([listZones count] != 1);
            return;
        }
        
        CCLog(@"%lu events received", [eventsDicts count]);
        NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
        NSDate *lastEventDate = nil;
        for (NSDictionary *eventDict in eventsDicts) {
            CCServerEvent *serverEvent = [CCServerEvent insertInManagedObjectContext:managedObjectContext fromLinotteAPIDict:eventDict];
            [list addServerEventsObject:serverEvent];
            lastEventDate = serverEvent.date;
        }
        listZone.lastEventDate = lastEventDate;
        [[CCCoreDataStack sharedInstance] saveContext];
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
