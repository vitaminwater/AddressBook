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

- (BOOL)listNeedProcess:(CCList *)list
{
    NSDate *minDate = [[NSDate date] dateByAddingTimeInterval:-(3 * 24 * 60 * 60)];
    return list.lastZonesRefresh == nil || [list.lastZonesRefresh compare:minDate] == NSOrderedAscending;
}

- (CCList *)findNextListToProcess
{
    NSDate *minDate = [[NSDate date] dateByAddingTimeInterval:-(3 * 24 * 60 * 60)];
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCList entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lastZonesRefresh < %@", minDate];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastZonesRefresh" ascending:YES];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    [fetchRequest setFetchLimit:1];
    NSArray *lists = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    
    if ([lists count] == 0)
        return nil;
    
    return [lists firstObject];
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
    
    NSLog(@"Stating CCListSynchronizationActionRefreshZone job");
    [[CCLinotteAPI sharedInstance] fetchListZones:list.identifier completionBlock:^(BOOL success, NSArray *listZones) {
        if (success) {
            NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCListZone entityName]];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"list = %@", list];
            [fetchRequest setPredicate:predicate];
            
            NSMutableArray *currentListZones = [[managedObjectContext executeFetchRequest:fetchRequest error:NULL] mutableCopy];
            NSMutableArray *newListZones = [listZones mutableCopy];
            NSMutableArray *splittedZones = [@[] mutableCopy];
            NSMutableArray *listZonesToDelete = [@[] mutableCopy];
            
            NSLog(@"List zones recieved, processing results");
            if ([currentListZones count] != 0) {
                
                // first we remove already existing list zones
                for (NSDictionary *listZoneDict in listZones) {
                    NSString *geohash = listZoneDict[@"geohash"];
                    for (CCListZone *currentListZone in currentListZones) {
                        if ([currentListZone.geohash isEqualToString:geohash]) {
                            [newListZones removeObject:listZoneDict];
                            [currentListZones removeObject:currentListZone];
                            NSLog(@"Zone %@ already exists", geohash);
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
                            NSLog(@"Split zone %@", currentListZone.geohash);
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
                            NSLog(@"Merge zone %@ into %@", currentListZone.geohash, geohash);
                        }
                    }
                }
                
            }
            
            for (NSDictionary *listZoneDict in newListZones) {
                CCListZone *listZone = [CCListZone insertInManagedObjectContext:managedObjectContext fromLinotteAPIDict:listZoneDict];
                for (CCListZone *splittedZone in splittedZones) {
                    if ([splittedZone.geohash rangeOfString:listZone.geohash].location == 0) {
                        listZone.lastEventDate = splittedZone.lastEventDate;
                        listZone.firstFetchValue = NO;
                        listZone.lastRefresh = splittedZone.lastRefresh;
                        break;
                    }
                }
                [list addZonesObject:listZone];
            }
            
            NSLog(@"Deleting %lu zones", (unsigned long)[listZonesToDelete count]);
            for (CCListZone *listZoneToDelete in listZonesToDelete) {
                [managedObjectContext deleteObject:listZoneToDelete];
            }
            
            list.lastZonesRefresh = [NSDate date];
            list.lastZoneRefreshLatitudeValue = coordinates.latitude;
            list.lastZoneRefreshLongitudeValue = coordinates.longitude;
            list.lastZoneCleaningLatitudeValue = coordinates.latitude;
            list.lastZoneCleaningLongitudeValue = coordinates.longitude;
            [[CCCoreDataStack sharedInstance] saveContext];
        }
        completionBlock(YES);
    }];
}

@end
