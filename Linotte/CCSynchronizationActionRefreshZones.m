//
//  CCSynchronizationActionRefreshZones.m
//  Linotte
//
//  Created by stant on 10/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCSynchronizationActionRefreshZones.h"

#import "CCCoreDataStack.h"

#import "CCLinotteAPI.h"

#import "CCList.h"
#import "CCListZone.h"

@implementation CCSynchronizationActionRefreshZones
{
    CCList *_currentList;
    NSURLSessionTask *_currentConnection;
}

- (BOOL)listNeedProcess:(CCList *)list
{
    NSDate *minDate = [[NSDate date] dateByAddingTimeInterval:-(3 * 24 * 60 * 60)];
    return list.lastZonesRefresh == nil || [list.lastZonesRefresh compare:minDate] == NSOrderedAscending;
}

- (CCList *)findNextListToProcess
{
    NSDate *minDate = [[NSDate date] dateByAddingTimeInterval:-(3 * 24 * 60 * 60)];
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCList entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lastZonesRefresh < %@", minDate];
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

- (void)triggerWithList:(CCList *)list coordinates:(CLLocationCoordinate2D)coordinates completionBlock:(void(^)(BOOL goOnSyncing))completionBlock
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
    
    CCLog(@"Stating CCListSynchronizationActionRefreshZone job");
    _currentList = list;
    _currentConnection = [[CCLinotteAPI sharedInstance] fetchListZones:list.identifier completionBlock:^(BOOL success, NSArray *listZones) {
        
        _currentList = nil;
        _currentConnection = nil;
        if (success == NO) {
            completionBlock(NO);
            return;
        }
        
        BOOL done = NO;
        NSError *error = nil;
        NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCListZone entityName]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"list = %@", list];
        [fetchRequest setPredicate:predicate];
        
        NSMutableArray *currentListZones = [[managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
        
        if (error != nil) {
            CCLog(@"%@", error);
            return;
        }
        
        NSMutableArray *newListZones = [listZones mutableCopy];
        NSMutableArray *splittedZones = [@[] mutableCopy];
        NSMutableArray *listZonesToDelete = [@[] mutableCopy];
        
        CCLog(@"List zones recieved, processing results");
        if ([currentListZones count] != 0) {
            
            // first we remove already existing list zones
            for (NSDictionary *listZoneDict in listZones) {
                NSString *geohash = listZoneDict[@"geohash"];
                for (CCListZone *currentListZone in currentListZones) {
                    if ([currentListZone.geohash isEqualToString:geohash]) {
                        [newListZones removeObject:listZoneDict];
                        [currentListZones removeObject:currentListZone];
                        CCLog(@"Zone %@ already exists", geohash);
                        break;
                    }
                }
            }
            
            // then we determine if the new list zones are splits of already existing listzones
            // if yes, then we delete it
            for (NSDictionary *listZoneDict in newListZones) {
                NSString *geohash = listZoneDict[@"geohash"];
                for (CCListZone *currentListZone in currentListZones) {
                    if ([currentListZone.geohash rangeOfString:geohash].location == 0) {
                        [splittedZones addObject:currentListZone];
                        CCLog(@"Split zone %@", currentListZone.geohash);
                        break;
                    }
                }
            }
            [currentListZones removeObjectsInArray:splittedZones];
            [listZonesToDelete addObjectsFromArray:splittedZones];
            
            // now we check the other way: if one of our zones have been merged in a bigger zone
            // if yes, then we delete the merged zones
            for (CCListZone *currentListZone in currentListZones) {
                for (NSDictionary *listZoneDict in listZones) {
                    NSString *geohash = listZoneDict[@"geohash"];
                    if ([geohash rangeOfString:currentListZone.geohash].location == 0) {
                        [listZonesToDelete addObject:currentListZone];
                        CCLog(@"Merge zone %@ into %@", currentListZone.geohash, geohash);
                    }
                }
            }
            
        }
        
        if ([newListZones count] != 0 || [listZonesToDelete count] != 0) {
            for (NSDictionary *listZoneDict in newListZones) {
                CCListZone *listZone = [CCListZone insertInManagedObjectContext:managedObjectContext fromLinotteAPIDict:listZoneDict];
                for (CCListZone *splittedZone in splittedZones) {
                    if ([splittedZone.geohash rangeOfString:listZone.geohash].location == 0) {
                        listZone.lastEventDate = splittedZone.lastEventDate;
                        listZone.firstFetchValue = NO;
                        listZone.lastUpdate = splittedZone.lastUpdate;
                        break;
                    }
                }
                [list addZonesObject:listZone];
            }
            
            CCLog(@"Deleting %lu zones", (unsigned long)[listZonesToDelete count]);
            for (CCListZone *listZoneToDelete in listZonesToDelete) {
                [managedObjectContext deleteObject:listZoneToDelete];
            }
            
            list.lastZonesRefresh = [NSDate date];
            list.lastZoneRefreshLatitudeValue = coordinates.latitude;
            list.lastZoneRefreshLongitudeValue = coordinates.longitude;
            list.lastZoneCleaningLatitudeValue = coordinates.latitude;
            list.lastZoneCleaningLongitudeValue = coordinates.longitude;
            [[CCCoreDataStack sharedInstance] saveContext];

            done = YES;
        }
        completionBlock(done);
    }];
}

#pragma mark - CCModelChangeMonitorDelegate

- (void)listWillRemove:(CCList *)list send:(BOOL)send
{
    if (_currentList == list)
        [_currentConnection cancel];
}

@end
