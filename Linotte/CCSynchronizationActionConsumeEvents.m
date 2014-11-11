//
//  CCSynchronizationActionConsumeEvents.m
//  Linotte
//
//  Created by stant on 10/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCSynchronizationActionConsumeEvents.h"

#import "CCCoreDataStack.h"

#import "CCLinotteAPI.h"

#import "CCList.h"
#import "CCListZone.h"
#import "CCServerEvent.h"

@implementation CCSynchronizationActionConsumeEvents

- (BOOL)listNeedProcess:(CCList *)list
{
    NSDate *minDate = [[NSDate date] dateByAddingTimeInterval:-(12 * 60 * 60)];
    return [list.serverEvents count] > 0 || [list.lastDateUpdate compare:minDate] == NSOrderedAscending;
}

- (CCList *)findNextListToProcess
{
    NSDate *minDate = [[NSDate date] dateByAddingTimeInterval:-(12 * 60 * 60)];

    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCList entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lastDateUpdate < %@ or serverEvents.@count > 0", minDate];
    [fetchRequest setPredicate:predicate];

    NSMutableArray *lists = [[managedObjectContext executeFetchRequest:fetchRequest error:NULL] mutableCopy];
    
    if ([lists count] == 0)
        return nil;
    
    NSSortDescriptor *eventNumberSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"serverEvents.@count" ascending:NO];
    NSSortDescriptor *lastUpdateSortDesciptor = [NSSortDescriptor sortDescriptorWithKey:@"lastDateUpdate" ascending:YES];
    [lists sortedArrayUsingDescriptors:@[eventNumberSortDescriptor, lastUpdateSortDesciptor]];
    
    CCList *list = [lists firstObject];
    
    if (list == nil)
        return nil;
    
    return list;
}

- (void)triggerWithList:(CCList *)list coordinates:(CLLocationCoordinate2D)coordinates completionBlock:(void(^)(BOOL done))completionBlock
{
    if (list != nil && [self listNeedProcess:list] == NO) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(NO);
        });
        return;
    }
    
    list = list ?: [self findNextListToProcess];
    if (list == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(NO);
        });
        return;
    }
    
    NSLog(@"Starting CCListSynchronizationActionConsumeZoneEvent job");
    
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCServerEvent entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"list = %@", list];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    fetchRequest.fetchLimit = 1;
    
    NSError *error = nil;
    NSArray *serverEvents = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(NO);
        });
        NSLog(@"%@", error);
        return;
    }
    
    if ([serverEvents count] == 0) {
        [self fetchServerEventsWithList:list completionBlock:^{
            completionBlock(YES);
        }];
        return;
    }
    
    CCServerEvent *serverEvent = [serverEvents lastObject];
    [self processServerEvent:serverEvent completionBlock:^(BOOL success){
        if (success) {
            [managedObjectContext deleteObject:serverEvent];
        }
        completionBlock(success);
    }];
}

- (void)fetchServerEventsWithList:(CCList *)list completionBlock:(void(^)())completionBlock
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCListZone entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"list = %@ and firstFetch = %@", list, @(NO)];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastRefresh" ascending:YES];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    fetchRequest.fetchLimit = 1;
    
    NSError *error = nil;
    NSArray *listZones = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error != nil) {
        dispatch_async(dispatch_get_main_queue(), completionBlock);
        NSLog(@"%@", error);
        return;
    }
    
    if ([listZones count] == 0) {
        dispatch_async(dispatch_get_main_queue(), completionBlock);
        return;
    }
    
    CCListZone *listZone = [listZones firstObject];
    [[CCLinotteAPI sharedInstance] fetchListEvents:list.identifier geohash:listZone.geohash lastDate:listZone.lastEventDate completionBlock:^(BOOL success, NSArray *eventsDicts) {
        if (success) {
            if ([eventsDicts count] == 0) {
                completionBlock();
                return;
            }
            
            NSLog(@"%lu events recieved", [eventsDicts count]);
            NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
            NSDate *lastEventDate = nil;
            for (NSDictionary *eventDict in eventsDicts) {
                CCServerEvent *serverEvent = [CCServerEvent insertInManagedObjectContext:managedObjectContext fromLinotteAPIDict:eventDict];
                [list addServerEventsObject:serverEvent];
                lastEventDate = serverEvent.date;
            }
            listZone.lastEventDate = lastEventDate;
            listZone.lastRefresh = [NSDate date];
            list.lastDateUpdate = [NSDate date];
            [[CCCoreDataStack sharedInstance] saveContext];
            completionBlock();
        }
    }];
}

- (void)processServerEvent:(CCServerEvent *)serverEvent completionBlock:(void(^)(BOOL success))completionBlock
{
    switch (serverEvent.eventValue) {
        case CCServerEventListUpdated:
        {
            [[CCLinotteAPI sharedInstance] fetchCompleteListInfos:serverEvent.list.identifier completionBlock:^(BOOL success, NSDictionary *listInfo) {
                if (success) {
                    
                }
                completionBlock(success);
            }];
        }
            break;
        case CCServerEventListMetaAdded:
        case CCServerEventListMetaUpdated:
        {
            
        }
            break;
        case CCServerEventListMetaDeleted:
        {
            
        }
            break;
        case CCServerEventAddressAddedToList:
        {
            
        }
            break;
        case CCServerEventAddressMovedFromList:
        {
            
        }
            break;
        case CCServerEventAddressUpdated:
        {
            
        }
            break;
        case CCServerEventAddressUserDataUpdated:
        {
            
        }
            break;
        case CCServerEventAddressMetaAdded:
        {
            
        }
            break;
        case CCServerEventAddressMetaUpdated:
        {
            
        }
            break;
        case CCServerEventAddressMetaDeleted:
        {
            
        }
            break;
        default:
            break;
    }
}

@end
