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

- (id)init
{
    self = [super init];
    if (self) {
        _delegates = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
        
        _locationManager = [CLLocationManager new];
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.delegate = self;
        
        if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
            [_locationManager startUpdatingLocation];
            [_locationManager startUpdatingHeading];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addDelegate:(id<CLLocationManagerDelegate>)delegate
{
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
}

- (void)applicationBackground:(NSNotification *)note
{
    [_locationManager stopUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
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

#pragma mark - singelton method

+ (instancetype)sharedInstance
{
    static id instance = nil;
    
    if (instance == nil)
        instance = [[self class] new];
    
    return instance;
}

@end
