//
//  CCLocationMonitor.m
//  Linotte
//
//  Created by stant on 25/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCLocationMonitor.h"

#import <objc/runtime.h>


@implementation CCLocationMonitor
{
    CLLocationManager *_locationManager;
    NSHashTable *_delegates;
    
    CLLocation *_currentLocation;
    CLHeading *_currentHeading;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _delegates = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
        
        _locationManager = [CLLocationManager new];
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        _locationManager.delegate = self;
        
        if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
            if (authorizationStatus == kCLAuthorizationStatusNotDetermined) {
                [_locationManager requestAlwaysAuthorization];
            } else if (authorizationStatus == kCLAuthorizationStatusAuthorizedAlways) {
                [self startLocalization];
            } else {
                // Print message. cf. didChangeAuthorizationStatus
            }
        } else {
            [self startLocalization];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)startLocalization
{
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
        [_locationManager startUpdatingLocation];
        [_locationManager startUpdatingHeading];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addDelegate:(id<CLLocationManagerDelegate>)delegate
{
    if ([_delegates containsObject:delegate])
        return;
    
    [_delegates addObject:delegate];
    
    if (_currentLocation && [delegate respondsToSelector:@selector(locationManager:didUpdateLocations:)])
        [delegate locationManager:_locationManager didUpdateLocations:@[_currentLocation]];
    
    if (_currentHeading && [delegate respondsToSelector:@selector(locationManager:didUpdateHeading:)])
        [delegate locationManager:_locationManager didUpdateHeading:_currentHeading];
}

- (void)removeDelegate:(id<CLLocationManagerDelegate>)delegate
{
    [_delegates removeObject:delegate];
}

#pragma mark - UINotificationCenter methods

- (void)applicationActive:(NSNotification *)note
{
    [_locationManager startUpdatingLocation];
    [_locationManager startUpdatingHeading];
}

- (void)applicationBackground:(NSNotification *)note
{
    [_locationManager stopUpdatingLocation];
    [_locationManager stopUpdatingHeading];
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        [_locationManager startUpdatingLocation];
        [_locationManager startUpdatingHeading];
    } else if (status == kCLAuthorizationStatusDenied) {
        // TODO print message
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
        CCLog(@"CCLocationMonitor locationManager:didUpdateLocations:");
    CLLocation *location = [locations lastObject];
    if (_currentLocation) {
        CGFloat distance = [location distanceFromLocation:_currentLocation];
        if (distance < 10)
            return;
    }
    
    _currentLocation = location;
    for (__weak id<CLLocationManagerDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(locationManager:didUpdateLocations:)])
            [delegate locationManager:manager didUpdateLocations:locations];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
        CCLog(@"CCLocationMonitor locationManager:didUpdateHeading:");
    _currentHeading = newHeading;
    for (__weak id<CLLocationManagerDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(locationManager:didUpdateHeading:)])
            [delegate locationManager:manager didUpdateHeading:newHeading];
    }
}

#pragma mark - forward

- (void)forwardInvocation:(NSInvocation *)invocation
{
    struct objc_method_description hasMethod = protocol_getMethodDescription(@protocol(CLLocationManagerDelegate), invocation.selector, NO, YES);
    
    if ( hasMethod.name != NULL ) {
        for (__weak id<CLLocationManagerDelegate> delegate in _delegates) {
            if ([delegate respondsToSelector:invocation.selector]) {
                [invocation invokeWithTarget:delegate];
            }
        }
    } else {
        [super forwardInvocation:invocation];
    }
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
