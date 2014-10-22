//
//  CCNotificationGenerator.m
//  AdRem
//
//  Created by stant on 09/02/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCGeohashMonitor.h"

#import "CCGeohashHelper.h"


@implementation CCGeohashMonitor
{
    CLLocationManager *_locationManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        if (![CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]] ||
            ![CLLocationManager significantLocationChangeMonitoringAvailable]) {
        }
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        
        [_locationManager startMonitoringSignificantLocationChanges];
    }
    return self;
}

- (void)updateMonitoredGeohashes:(CLLocationCoordinate2D)coordinates
{
    NSMutableArray *geohashes = [[CCGeohashHelper geohashGridSurroundingCoordinate:coordinates radius:2 digits:kCCGeohashHelperNDigits all:NO] mutableCopy];
    
    for (CLRegion *region in _locationManager.monitoredRegions) {
        if (![geohashes containsObject:region.identifier]) {
            [_locationManager stopMonitoringForRegion:region];
        } else {
            [geohashes removeObject:region.identifier];
        }
    }
    for (NSString *geohash in geohashes) {
        CLLocationCoordinate2D coord = [CCGeohashHelper coordinatesFromGeohash:geohash];
        CLRegion *region = [[CLCircularRegion alloc] initWithCenter:coord radius:100 identifier:geohash];
        [_locationManager startMonitoringForRegion:region];
    }
}

#pragma mark - CLLocationManagerDelegate methods

#pragma mark region monitoring methods

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    if ([region isKindOfClass:[CLCircularRegion class]]) {
        NSArray *geohashes = [CCGeohashHelper calculateAdjacentGeohashes:region.identifier];
        [_delegate didEnterGeohash:geohashes];
        [self updateMonitoredGeohashes:((CLCircularRegion *)region).center];
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
}

#pragma mark significant location change monitoring

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    [self updateMonitoredGeohashes:location.coordinate];
}

#pragma mark - Singleton method

+ (instancetype)sharedInstance
{
    static id instance = nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        instance = [self new];
    });
    
    return instance;
}

@end
