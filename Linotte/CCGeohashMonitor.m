//
//  CCNotificationGenerator.m
//  AdRem
//
//  Created by stant on 09/02/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCGeohashMonitor.h"

#import <RestKit/RestKit.h>

#import "CCGeohashHelper.h"

@interface CCGeohashMonitor()
{
    CLLocationManager *_locationManager;
}

@end

@implementation CCGeohashMonitor

- (id)init
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
    NSMutableArray *geohashes = [[CCGeohashHelper geohashGridSurroundingCoordinate:coordinates] mutableCopy];
    
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

#pragma mark - singelton method

+ (CCGeohashMonitor *)sharedInstance
{
    static CCGeohashMonitor *instance = nil;
    
    if (instance == nil)
        instance = [CCGeohashMonitor new];
    
    return instance;
}

@end
