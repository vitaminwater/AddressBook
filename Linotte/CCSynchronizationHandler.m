//
//  CCSynchronizationHandler.m
//  Linotte
//
//  Created by stant on 30/10/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCSynchronizationHandler.h"

#import <AFNetworking/AFNetworkReachabilityManager.h>

#import "CCSynchronizationActionProtocol.h"
#import "CCSynchronizationActionInitialListFetch.h"
#import "CCSynchronizationActionSendLocalEvents.h"
#import "CCUserSynchronizationActionConsumeEvents.h"
#import "CCSynchronizationActionRefreshZones.h"
#import "CCSynchronizationActionCleanUselessZones.h"
#import "CCListSynchronizationActionInitialAddressFetch.h"
#import "CCListSynchronizationActionConsumeEvents.h"
#import "CCListZoneSynchronizationActionConsumeEvents.h"

#import "CCLinotteAPI.h"
#import "CCModelChangeHandler.h"
#import "CCNetworkLogs.h"

#import "CCModelChangeMonitor.h"
#import "CCLocationMonitor.h"

#import "CCGeohashHelper.h"
#import "CCLinotteCoreDataStack.h"

#import "CCList.h"
#import "CCAddress.h"
#import "CCListZone.h"

#define kCCLastCoordinateKey @"kCCLastCoordinateKey"

/**
 * CCSynchronizationHandler
 */


@implementation CCSynchronizationHandler
{
    CLLocationManager *_locationManager;
    CLLocationCoordinate2D _lastCoordinate;
    
    BOOL _syncedListChanged;
    NSUInteger _synchronizationActionIndex;
    NSArray *_synchronizationActions;
    CCList *_syncedList;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupSynchronizationActions];
        
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
        
        [_locationManager startMonitoringSignificantLocationChanges];
        
        [[CCLocationMonitor sharedInstance] addDelegate:self];
    }
    return self;
}

- (void)setupSynchronizationActions
{
    _synchronizationActions = @[[CCSynchronizationActionSendLocalEvents new],
                                [CCSynchronizationActionInitialListFetch new],
                                [CCUserSynchronizationActionConsumeEvents new],
                                [CCSynchronizationActionRefreshZones new],
                                [CCSynchronizationActionCleanUselessZones new],
                                [CCListSynchronizationActionInitialAddressFetch new],
                                [CCListSynchronizationActionConsumeEvents new],
                                [CCListZoneSynchronizationActionConsumeEvents new]];
}

#pragma mark - Zone synchronization methods

- (void)performSynchronizationsWithMaxDuration:(NSTimeInterval)maxDuration list:(CCList *)list completionBlock:(void(^)(BOOL didSync))completionBlock
{
    if ([AFNetworkReachabilityManager sharedManager].isReachable == NO || [self lastCoordinateAvailable] == NO)
        return;
    
    if (list != nil && list.identifier == nil)
        return;
    
    if (list != _syncedList) {
        _syncedList = list;
        _syncedListChanged = YES;
        _synchronizationActionIndex = 0;
    }
    
    if (_syncing == YES)
        return;
    
    _syncing = YES;
    _synchronizationActionIndex = 0;
    NSTimeInterval startSync = [NSDate timeIntervalSinceReferenceDate];
    [self performSynchronizationIterationWithStartSync:startSync maxDuration:maxDuration didSync:NO completionBlock:completionBlock];
}

- (void)performSynchronizationIterationWithStartSync:(NSTimeInterval)startSync maxDuration:(NSTimeInterval)maxDuration didSync:(BOOL)didSync completionBlock:(void(^)(BOOL didSync))completionBlock
{
    if (_synchronizationActionIndex >= [_synchronizationActions count]) {
        _syncedList = nil;
        _syncing = NO;
        completionBlock(didSync);
        return;
    }
    
    NSTimeInterval timeElapsed = [NSDate timeIntervalSinceReferenceDate] - startSync;
    if (maxDuration != 0 && timeElapsed >= maxDuration) {
        _syncedList = nil;
        _syncing = NO;
        completionBlock(didSync);
        return;
    }
    
    id<CCSynchronizationActionProtocol> synchronizationAction = _synchronizationActions[_synchronizationActionIndex];
    [synchronizationAction triggerWithList:_syncedList coordinates:_lastCoordinate completionBlock:^(BOOL goOnSyncing, BOOL error) {
        if (error) {
            _syncedList = nil;
            _syncing = NO;
            completionBlock(didSync);
            return;
        }
        if (_syncedListChanged == NO) {
            if (goOnSyncing == YES)
                _synchronizationActionIndex = 0;
            else
                _synchronizationActionIndex++;
        } else {
            _syncedListChanged = NO;
        }
        [self performSynchronizationIterationWithStartSync:startSync maxDuration:maxDuration didSync:didSync | goOnSyncing completionBlock:completionBlock];
    }];
}

#pragma mark significant location change monitoring

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    
    _lastCoordinate = location.coordinate;
    [self storeLastCoordinates];
}

- (void)storeLastCoordinates
{
    NSString *coordinateString = [NSString stringWithFormat:@"%f,%f", _lastCoordinate.latitude, _lastCoordinate.longitude];
    [[NSUserDefaults standardUserDefaults] setValue:coordinateString forKey:kCCLastCoordinateKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadLastCoordinates
{
    NSString *coordinateString = [[NSUserDefaults standardUserDefaults] valueForKey:kCCLastCoordinateKey];
    if (coordinateString == nil)
        return;
    NSArray *coordinateSplit = [coordinateString componentsSeparatedByString:@","];
    CLLocationDegrees latitude = [((NSString *)coordinateSplit[0]) doubleValue];
    CLLocationDegrees longitude = [((NSString *)coordinateSplit[1]) doubleValue];
    _lastCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
}

- (BOOL)lastCoordinateAvailable
{
    return _lastCoordinate.latitude != 0 && _lastCoordinate.longitude != 0;
}

@end
