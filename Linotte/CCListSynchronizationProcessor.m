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
#import "CCListGeohashZone+CCListZone.h"
#import "CCAddressModel+CCAddress.h"

#import "CCList.h"
#import "CCListZone.h"
#import "CCServerEvent.h"

#define kCCMaxAddressesForList 1000
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

@end

/**
 * Refresh zone action
 */

@interface CCListSynchronizationActionRefreshZone : BaseListSynchronizationAction
@end

@implementation CCListSynchronizationActionRefreshZone

- (void)performSynchronizationWithCompletionBlock:(void(^)())completionBlock
{
    [[CCLinotteAPI sharedInstance] fetchListZones:self.list.identifier completionBlock:^(BOOL success, NSArray *listZones) {
        if (success) {
            NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
            for (CCListGeohashZoneModel *listGeohashZone in listZones) {
                CCListZone *listZone = [listGeohashZone toInsertedCCListZoneInManagedObjectContext:managedObjectContext];
                [self.list addZonesObject:listZone];
            }
            self.list.lastZonesRefresh = [NSDate date];
            self.list.lastZoneRefreshLatitudeValue = self.coordinates.latitude;
            self.list.lastZoneRefreshLongitudeValue = self.coordinates.longitude;
            [[CCCoreDataStack sharedInstance] saveContext];
        }
        completionBlock();
    }];
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
    
    for (CCListZone *zone in sortedZones) {
        if (zone.firstFetchValue == NO)
            continue;
        [[CCLinotteAPI sharedInstance] fetchAddressesFromList:self.list.identifier geohash:zone.geohash lastAddressDate:zone.lastAddressFirstFetchDate limit:kCCAddressFetchLimit completionBlock:^(BOOL success, NSArray *addresses) {
            if (success == NO) {
                completionBlock();
                return;
            }
            NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
            if ([addresses count] != kCCAddressFetchLimit)
                zone.firstFetchValue = NO;
            NSDate *lastAddressFirstFetchDate = nil;
            for (CCAddressModel *addressModel in addresses) {
                CCAddress *address = [addressModel toInsertedCCAddressZoneInManagedObjectContext:managedObjectContext];
                [self.list addAddressesObject:address];
                [[CCModelChangeMonitor sharedInstance] addressDidAdd:address fromNetwork:YES];
                lastAddressFirstFetchDate = addressModel.dateCreated;
            }
            zone.lastAddressFirstFetchDate = lastAddressFirstFetchDate;
            [[CCCoreDataStack sharedInstance] saveContext];
            completionBlock();
        }];
        break;
    }
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
    dispatch_async(dispatch_get_main_queue(), completionBlock);
    
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCServerEvent entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"list = %@", self.list];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
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
    
    
}

- (void)fetchServerEventsWithCompletionBlock:(void(^)())completionBlock
{
    
    [[CCLinotteAPI sharedInstance] fetchListEvents:self.list.identifier geohash:@"" lastId:@0 completionBlock:^(BOOL success, NSArray *events) {
        if (success) {
            
        }
    }];
}

- (void)processServerEvent:(CCServerEvent *)serverEvent
{
    
}

@end



@implementation CCListSynchronizationProcessor
{
    CLLocationCoordinate2D _currentLocation;
}

- (instancetype)initWithList:(CCList *)list currentLocation:(CLLocationCoordinate2D)currentLocation
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
    NSDate *lastZonesRefresh = _list.lastZonesRefresh;
    if (lastZonesRefresh == nil || [[NSDate date] timeIntervalSinceDate:lastZonesRefresh] > 3 * 24 * 60 * 60) {
        _priority = NSIntegerMax;
        _synchronizationAction = [[CCListSynchronizationActionRefreshZone alloc] initWithList:_list coordinates:_currentLocation];
        return;
    }
    
    NSInteger totalNAddresses = [[_list.zones valueForKeyPath:@"@sum.nAddresses"] integerValue];
    NSInteger currentNAddresses = [_list.addresses count];
    
    if (currentNAddresses < totalNAddresses && currentNAddresses < kCCMaxAddressesForList) {
        _priority = NSIntegerMax;
        _synchronizationAction = [[CCListSynchronizationActionInitialAddressFetch alloc] initWithList:_list coordinates:_currentLocation];
        return;
    }
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:_currentLocation.latitude longitude:_currentLocation.longitude];
    CLLocation *listLastZoneRefreshLocation = [[CLLocation alloc] initWithLatitude:_list.lastZoneRefreshLatitudeValue longitude:_list.lastZoneRefreshLongitudeValue];
    CGFloat distance = [location distanceFromLocation:listLastZoneRefreshLocation];
    
    if (currentNAddresses < totalNAddresses && currentNAddresses >= kCCMaxAddressesForList && distance > 3000) {
        _priority = NSIntegerMax;
        _synchronizationAction = [[CCListSynchronizationActionCleanUselessZones alloc] initWithList:_list coordinates:_currentLocation];
        return;
    }
    
    NSDate *lastUpdate = _list.lastDateUpdate;
    _priority = [[NSDate date] timeIntervalSinceDate:lastUpdate];
    _synchronizationAction = [[CCListSynchronizationActionConsumeZoneEvent alloc] initWithList:_list coordinates:_currentLocation];
}

@end
