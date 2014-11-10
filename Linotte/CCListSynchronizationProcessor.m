//
//  CCListSynchronizationAction.m
//  Linotte
//
//  Created by stant on 02/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListSynchronizationProcessor.h"

#import <CoreLocation/CoreLocation.h>

#import "CCModelChangeMonitor.h"

#import "CCCoreDataStack.h"

#import "CCLinotteAPI.h"

#import "CCList.h"
#import "CCListZone.h"
#import "CCServerEvent.h"
#import "CCAddress.h"

#define kCCMaxAddressesForList 600
#define kCCAddressFetchLimit 50




/**
 * Base List synchronization Action
 */

@interface BaseListSynchronizationAction : NSObject<CCListSynchronizationActionProtocol>

@property(nonatomic, readonly)CCList *list;
@property(nonatomic, readonly)CLLocationCoordinate2D coordinates;

@end

@implementation BaseListSynchronizationAction

- (instancetype)initWithList:(CCList *)list coordinates:(CLLocationCoordinate2D)coordinates
{
    self = [super init];
    if (self) {
        _list = list;
        _coordinates = coordinates;
    }
    return self;
}

- (void)performSynchronizationWithCompletionBlock:(void(^)())completionBlock {}

+ (BOOL)canTrigger:(CCList *)list coordinates:(CLLocationCoordinate2D)coordinates {return NO;}

@end




/**
 * Refresh zone action
 */

@interface CCListSynchronizationActionRefreshZone : BaseListSynchronizationAction
@end

@implementation CCListSynchronizationActionRefreshZone

- (void)performSynchronizationWithCompletionBlock:(void(^)())completionBlock
{
    NSLog(@"Stating CCListSynchronizationActionRefreshZone job");
    [[CCLinotteAPI sharedInstance] fetchListZones:self.list.identifier completionBlock:^(BOOL success, NSArray *listZones) {
        if (success) {
            NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCListZone entityName]];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"list = %@", self.list];
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
                        listZone.lastEventId = splittedZone.lastEventId;
                        listZone.firstFetchValue = NO;
                        listZone.lastRefresh = splittedZone.lastRefresh;
                        break;
                    }
                }
                [self.list addZonesObject:listZone];
            }
            
            NSLog(@"Deleting %lu zones", [listZonesToDelete count]);
            for (CCListZone *listZoneToDelete in listZonesToDelete) {
                [managedObjectContext deleteObject:listZoneToDelete];
            }

            self.list.lastZonesRefresh = [NSDate date];
            self.list.lastZoneRefreshLatitudeValue = self.coordinates.latitude;
            self.list.lastZoneRefreshLongitudeValue = self.coordinates.longitude;
            [[CCCoreDataStack sharedInstance] saveContext];
        }
        completionBlock();
    }];
}

//

+ (BOOL)canTrigger:(CCList *)list coordinates:(CLLocationCoordinate2D)coordinates
{
    NSDate *lastZonesRefresh = list.lastZonesRefresh;
    NSTimeInterval timeIntervalSinceLastZonesRefresh = [[NSDate date] timeIntervalSinceDate:lastZonesRefresh];
    return lastZonesRefresh == nil || timeIntervalSinceLastZonesRefresh > 3 * 24 * 60 * 60;
}

@end




/**
 * Clean useless zones
 */

@interface CCListSynchronizationActionCleanUselessZones : BaseListSynchronizationAction
@end

@implementation CCListSynchronizationActionCleanUselessZones

- (void)performSynchronizationWithCompletionBlock:(void(^)())completionBlock
{
    dispatch_async(dispatch_get_main_queue(), completionBlock);
}

+ (BOOL)canTrigger:(CCList *)list coordinates:(CLLocationCoordinate2D)coordinates
{
    NSInteger totalNAddresses = [[list.zones valueForKeyPath:@"@sum.nAddresses"] integerValue];
    NSInteger currentNAddresses = [list.addresses count];
    if (currentNAddresses == totalNAddresses)
        return NO;
    
    NSLog(@"Starting CCListSynchronizationActionCleanUselessZones job");
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    NSArray *sortedZones = [list getListZonesSortedByDistanceFromLocation:coordinates];
    NSUInteger addressCounter = 0;
    BOOL cleaned = NO;
    NSMutableArray *removedAddresses = [@[] mutableCopy];
    for (CCListZone *listZone in sortedZones) {
        if (addressCounter > kCCMaxAddressesForList && (listZone.firstFetchValue == NO || listZone.lastAddressFirstFetchDate != nil)) {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(ANY lists = %@) AND (geohash BEGINSWITH %@)", list, listZone.geohash];
            [fetchRequest setPredicate:predicate];
            
            NSError *error = nil;
            NSArray *addresses = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
            if (error != nil) {
                NSLog(@"%@", error);
                continue;
            }
            
            cleaned = YES;
            
            NSLog(@"Cleaning %@ zone", listZone.geohash);
            [removedAddresses addObjectsFromArray:addresses];
            
            listZone.firstFetch = @YES;
            listZone.lastAddressFirstFetchDate = nil;
            listZone.lastRefresh = nil;
        }
        addressCounter += listZone.nAddressesValue;
    }
    
    [[CCModelChangeMonitor sharedInstance] addresses:removedAddresses willMoveFromList:list send:NO];
    [list removeAddresses:[NSSet setWithArray:removedAddresses]];
    [[CCCoreDataStack sharedInstance] saveContext];
    [[CCModelChangeMonitor sharedInstance] addresses:removedAddresses didMoveFromList:list send:NO];
    
    for (CCAddress *address in removedAddresses) {
        if ([address.lists count] == 0)
            [managedObjectContext deleteObject:address];
    }
    [[CCCoreDataStack sharedInstance] saveContext];
    return cleaned;
}

@end




/**
 * Load initial addresses for zones
 */

@interface CCListSynchronizationActionInitialAddressFetch : BaseListSynchronizationAction

@end

@implementation CCListSynchronizationActionInitialAddressFetch

- (void)performSynchronizationWithCompletionBlock:(void(^)())completionBlock
{
    NSArray *sortedZones = [self.list getListZonesSortedByDistanceFromLocation:self.coordinates];
    
    NSLog(@"Starting CCListSynchronizationActionInitialAddressFetch job");
    for (CCListZone *zone in sortedZones) {
        if (zone.firstFetchValue == NO)
            continue;
        [[CCLinotteAPI sharedInstance] fetchAddressesFromList:self.list.identifier geohash:zone.geohash lastAddressDate:zone.lastAddressFirstFetchDate limit:kCCAddressFetchLimit completionBlock:^(BOOL success, NSArray *addressesDicts) {
            if (success == NO) {
                completionBlock();
                return;
            }
            NSLog(@"Fetching zone %@", zone.geohash);
            NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
            if ([addressesDicts count] != kCCAddressFetchLimit) {
                zone.firstFetchValue = NO;
                NSLog(@"Zone %@ completed", zone.geohash);
            }
            NSDate *lastAddressFirstFetchDate = nil;
            NSMutableArray *addresses = [@[] mutableCopy];
            for (NSDictionary *addressDict in addressesDicts) {
                CCAddress *address = [CCAddress insertInManagedObjectContext:managedObjectContext fromLinotteAPIDict:addressDict];
                [addresses addObject:address];
                lastAddressFirstFetchDate = addressDict[@"date_created"];
            }
            
            [[CCModelChangeMonitor sharedInstance] addresses:addresses willMoveToList:self.list send:NO];
            [self.list addAddresses:[NSSet setWithArray:addresses]];
            [[CCCoreDataStack sharedInstance] saveContext];
            [[CCModelChangeMonitor sharedInstance] addresses:addresses didMoveToList:self.list send:NO];
            
            self.list.lastDateUpdate = [NSDate date];
            
            zone.lastAddressFirstFetchDate = lastAddressFirstFetchDate;
            [[CCCoreDataStack sharedInstance] saveContext];
            completionBlock();
        }];
        break;
    }
}

+ (BOOL)canTrigger:(CCList *)list coordinates:(CLLocationCoordinate2D)coordinates
{
    NSInteger totalNAddresses = [[list.zones valueForKeyPath:@"@sum.nAddresses"] integerValue];
    NSInteger currentNAddresses = [list.addresses count];
    return currentNAddresses < totalNAddresses && currentNAddresses < kCCMaxAddressesForList;
}

@end




/**
 * Consume zone events
 */

@interface CCListSynchronizationActionConsumeZoneEvent : BaseListSynchronizationAction
@end

@implementation CCListSynchronizationActionConsumeZoneEvent

- (void)performSynchronizationWithCompletionBlock:(void(^)())completionBlock
{
    NSLog(@"Starting CCListSynchronizationActionConsumeZoneEvent job");
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCServerEvent entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"list = %@", self.list];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    fetchRequest.fetchLimit = 1;
    
    NSError *error = nil;
    NSArray *serverEvents = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error != nil) {
        NSLog(@"%@", error);
        return;
    }
    
    if ([serverEvents count] == 0) {
        [self fetchServerEventsWithCompletionBlock:completionBlock];
        return;
    }
    
    [self processServerEvent:[serverEvents lastObject] completionBlock:completionBlock];
}

- (void)fetchServerEventsWithCompletionBlock:(void(^)())completionBlock
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCListZone entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"list = %@ and firstFetch = %@", self.list, @(NO)];
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
    [[CCLinotteAPI sharedInstance] fetchListEvents:self.list.identifier geohash:listZone.geohash lastId:listZone.lastEventId completionBlock:^(BOOL success, NSArray *eventsDicts) {
        if (success) {
            if ([eventsDicts count] == 0) {
                completionBlock();
                return;
            }
            
            NSLog(@"%lu events recieved", [eventsDicts count]);
            NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
            NSNumber *lastEventId = nil;
            for (NSDictionary *eventDict in eventsDicts) {
                CCServerEvent *serverEvent = [CCServerEvent insertInManagedObjectContext:managedObjectContext fromLinotteAPIDict:eventDict];
                [self.list addServerEventsObject:serverEvent];
                lastEventId = serverEvent.id;
            }
            listZone.lastEventId = lastEventId;
            listZone.lastRefresh = [NSDate date];
            self.list.lastDateUpdate = [NSDate date];
            [[CCCoreDataStack sharedInstance] saveContext];
            completionBlock();
        }
    }];
}

- (void)processServerEvent:(CCServerEvent *)serverEvent completionBlock:(void(^)())completionBlock
{
    switch (serverEvent.eventValue) {
        case CCServerEventListUpdated:
            
            break;
        case CCServerEventListMetaAdded:
            
            break;
        case CCServerEventListMetaUpdated:
            
            break;
        case CCServerEventListMetaDeleted:
            
            break;
        case CCServerEventAddressAddedToList:
            
            break;
        case CCServerEventAddressMovedFromList:
            
            break;
        case CCServerEventAddressUpdated:
            
            break;
        case CCServerEventAddressUserDataUpdated:
            
            break;
        case CCServerEventAddressMetaAdded:
            
            break;
        case CCServerEventAddressMetaUpdated:
            
            break;
        case CCServerEventAddressMetaDeleted:
            
            break;
        default:
            break;
    }
}

+ (BOOL)canTrigger:(CCList *)list coordinates:(CLLocationCoordinate2D)coordinates
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCServerEvent entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"list = %@", list];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSUInteger count = [managedObjectContext countForFetchRequest:fetchRequest error:&error];
    if (error != nil) {
        NSLog(@"%@", error);
        return NO;
    }
    
    NSTimeInterval timeSinceLastUpdate = [[NSDate date] timeIntervalSinceDate:list.lastDateUpdate];
    if (count == 0 && timeSinceLastUpdate < 24 * 60 * 60)
        return NO;
    
    return YES;
}

@end




@implementation CCListSynchronizationProcessor
{
    CLLocationCoordinate2D _currentLocation;
}

- (instancetype)initWithList:(CCList *)list coordinates:(CLLocationCoordinate2D)currentLocation
{
    self = [super init];
    if (self) {
        _currentLocation = currentLocation;
        _list = list;
        [self setupSynchronizationAction];
    }
    return self;
}

- (void)setupSynchronizationAction
{
    if ([CCListSynchronizationActionRefreshZone canTrigger:_list coordinates:_currentLocation]) {
        _priority = NSIntegerMax;
        _synchronizationAction = [[CCListSynchronizationActionRefreshZone alloc] initWithList:_list coordinates:_currentLocation];
        return;
    }
    
    if ([CCListSynchronizationActionCleanUselessZones canTrigger:_list coordinates:_currentLocation] || [CCListSynchronizationActionInitialAddressFetch canTrigger:_list coordinates:_currentLocation]) {
        _priority = NSIntegerMax;
        _synchronizationAction = [[CCListSynchronizationActionInitialAddressFetch alloc] initWithList:_list coordinates:_currentLocation];
        return;
    }
    
    if ([CCListSynchronizationActionConsumeZoneEvent canTrigger:_list coordinates:_currentLocation]) {
        NSDate *lastUpdate = _list.lastDateUpdate;
        _priority = [[NSDate date] timeIntervalSinceDate:lastUpdate];
        _synchronizationAction = [[CCListSynchronizationActionConsumeZoneEvent alloc] initWithList:_list coordinates:_currentLocation];
        return;
    }
}

@end
