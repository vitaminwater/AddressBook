//
//  CCSynchronizationActionRefreshZones.m
//  Linotte
//
//  Created by stant on 10/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCSynchronizationActionRefreshZones.h"

#import "CCLinotteCoreDataStack.h"

#import "CCLinotteAPI.h"
#import "CCLinotteEngineCoordinator.h"
#import "CCModelChangeMonitor.h"

#import "CCList.h"
#import "CCListZone.h"

#if defined(CCSHORT_REFRESH)
#define kCCDateIntervalDifference -20
#else
#define kCCDateIntervalDifferenceBackground -(24 * 60 * 60)
#define kCCDateIntervalDifferenceActive -(60 * 60)
#endif

@implementation CCSynchronizationActionRefreshZones
{
    CCList *_currentList;
    NSURLSessionTask *_currentConnection;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[CCModelChangeMonitor sharedInstance] addDelegate:self];
    }
    return self;
}

- (BOOL)listNeedProcess:(CCList *)list
{
    NSDate *minDate = [[NSDate date] dateByAddingTimeInterval:kCCApplicationBackground ? kCCDateIntervalDifferenceBackground : kCCDateIntervalDifferenceActive];
    return list.lastZonesRefresh == nil || [list.lastZonesRefresh compare:minDate] == NSOrderedAscending;
}

- (CCList *)findNextListToProcess
{
    NSDate *minDate = [[NSDate date] dateByAddingTimeInterval:kCCApplicationBackground ? kCCDateIntervalDifferenceBackground : kCCDateIntervalDifferenceActive];
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCList entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier != nil and (needsRefreshZone = %@ or lastZonesRefresh = nil or lastZonesRefresh < %@) and subquery(zones, $zone, $zone.firstFetch = %@ and $zone.lastAddressFirstFetchDate != nil).@count = 0", @YES, minDate, @YES];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastZonesRefresh" ascending:YES];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    [fetchRequest setFetchLimit:1];
    NSArray *lists = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        CCLog(@"%@", error);
        return nil;
    }
    
    if ([lists count] == 0)
        return nil;
    
    return [lists firstObject];
}

- (void)triggerWithList:(CCList *)list coordinates:(CLLocationCoordinate2D)coordinates completionBlock:(CCSynchronizationCompletionBlock)completionBlock
{
    if (list != nil && [self listNeedProcess:list] == NO) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(NO, NO);
        });
        return;
    }
    
    list = list ?: [self findNextListToProcess];
    if (list == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(NO, NO);
        });
        return;
    }
    
    CCLog(@"Stating CCSynchronizationActionRefreshZones job");
    _currentList = list;
    _currentConnection = [CCLEC.linotteAPI fetchListZones:list.identifier success:^(NSArray *listZones) {
        _currentList = nil;
        _currentConnection = nil;

        NSError *error = nil;
        NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCListZone entityName]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"list = %@", list];
        [fetchRequest setPredicate:predicate];
        
        NSMutableArray *currentListZones = [[managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
        
        list.needsRefreshZoneValue = NO;
        list.lastZonesRefresh = [NSDate date];
        
        if (error != nil) {
            [[CCLinotteCoreDataStack sharedInstance] saveContext];
            completionBlock(NO, NO);
            CCLog(@"%@", error);
            return;
        }
        
        NSMutableArray *newListZones = [listZones mutableCopy];
        NSMutableSet *splittedZones = [NSMutableSet new];
        NSMutableSet *listZonesToDelete = [NSMutableSet new];
        NSMutableDictionary *mergedZones = [@{} mutableCopy];
        
        CCLog(@"List zones recieved, processing results");
        if ([currentListZones count] != 0) {
            
            // first we remove already existing list zones
            for (NSDictionary *listZoneDict in listZones) {
                NSString *geohash = listZoneDict[@"geohash"];
                for (CCListZone *currentListZone in currentListZones) {
                    if ([currentListZone.geohash isEqualToString:geohash]) {
                        currentListZone.nAddresses = listZoneDict[@"n_addresses"];
                        [newListZones removeObject:listZoneDict];
                        [currentListZones removeObject:currentListZone];
                        CCLog(@"Zone %@ already exists", geohash);
                        break;
                    }
                }
            }
            
            // then we determine if one of the new list zones are splits of already existing listzones
            // if yes, then we delete it
            for (NSDictionary *listZoneDict in newListZones) {
                NSString *geohash = listZoneDict[@"geohash"];
                for (CCListZone *currentListZone in currentListZones) {
                    if ([geohash hasPrefix:currentListZone.geohash]) {
                        [splittedZones addObject:currentListZone];
                        CCLog(@"Split zone %@", currentListZone.geohash);
                        break;
                    }
                }
            }
            [currentListZones removeObjectsInArray:[splittedZones allObjects]];
            [listZonesToDelete addObjectsFromArray:[splittedZones allObjects]];
            
            // now we check the other way: if some of our zones have been merged in a bigger zone
            for (CCListZone *currentListZone in currentListZones) {
                for (NSDictionary *listZoneDict in newListZones) {
                    NSString *geohash = listZoneDict[@"geohash"];
                    if ([currentListZone.geohash hasPrefix:geohash]) {
                        if (mergedZones[geohash] == nil) {
                            mergedZones[geohash] = [@{@"listZoneDict" : listZoneDict, @"zones" : [@[] mutableCopy]} mutableCopy];
                        }
                        [mergedZones[geohash][@"zones"] addObject:currentListZone];
                        CCLog(@"Merge zone %@ into %@", currentListZone.geohash, geohash);
                    }
                }
            }
            
            if ([mergedZones count] != 0) {
                // if we have merged zones, first check if they are all unloaded, if yes, we can delete them and add the new one.
                for (NSString *geohash in [mergedZones allKeys]) {
                    NSDictionary *listZoneDict = mergedZones[geohash][@"listZoneDict"];
                    NSArray *zones = mergedZones[geohash][@"zones"];
                    BOOL canBeAdded = NO;
                    
                    CCLog(@"Zone %@ has %d zones to merge in.", geohash, [zones count]);
                    for (CCListZone *zone in zones) {
                        if (!zone.firstFetchValue) {
                            canBeAdded = NO;
                            break;
                        }
                    }
                    // new list zone can be added, remove old zones
                    if (canBeAdded) {
                        [listZonesToDelete addObjectsFromArray:zones];
                    } else {
                        // no it can't be added, remove the new one, and mark the old ones as needing merging
                        [newListZones removeObject:listZoneDict];
                        for (CCListZone *zone in zones) {
                            zone.needsMerge = geohash;
                            zone.readyToMergeValue = NO;
                        }
                    }
                }
            }
        }
        
        for (NSDictionary *listZoneDict in newListZones) {
            CCListZone *listZone = [CCListZone insertInManagedObjectContext:managedObjectContext fromLinotteAPIDict:listZoneDict];
            for (CCListZone *splittedZone in splittedZones) {
                if ([listZone.geohash hasPrefix:splittedZone.geohash]) {
                    listZone.lastEventDate = splittedZone.lastEventDate;
                    listZone.lastUpdate = splittedZone.lastUpdate;
                    listZone.firstFetchValue = splittedZone.firstFetchValue;
                    listZone.lastAddressFirstFetchDate = splittedZone.lastAddressFirstFetchDate;
                    break;
                }
            }
            [list addZonesObject:listZone];
        }
        
        CCLog(@"Deleting %lu zones", (unsigned long)[listZonesToDelete count]);
        for (CCListZone *listZoneToDelete in listZonesToDelete) {
            [managedObjectContext deleteObject:listZoneToDelete];
        }
        
        list.lastZoneCleaningLatitudeValue = coordinates.latitude;
        list.lastZoneCleaningLongitudeValue = coordinates.longitude;
        [[CCLinotteCoreDataStack sharedInstance] saveContext];
        
        completionBlock([newListZones count] != 0 || [listZonesToDelete count] != 0 || [mergedZones count] != 0, NO);
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
