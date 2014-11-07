//
//  CCSynchronizationHandler.m
//  Linotte
//
//  Created by stant on 30/10/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCSynchronizationHandler.h"

#import <Reachability/Reachability.h>

#import "CCLinotteAPI.h"
#import "CCNetworkHandler.h"

#import "CCModelChangeMonitor.h"
#import "CCLocationMonitor.h"

#import "CCGeohashHelper.h"
#import "CCCoreDataStack.h"

#import "CCListSynchronizationProcessor.h"

#import "CCList.h"
#import "CCAddress.h"
#import "CCListZone.h"

#define kCCLastCoordinateKey @"kCCLastCoordinateKey"

/**
 * CCSynchronizationHandler
 */


@implementation CCSynchronizationHandler
{
    NSTimer *_timer;
    
    CLLocationManager *_locationManager;
    
    CLLocationCoordinate2D _lastCoordinate;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reachabilityChanged:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
        
        [[CCModelChangeMonitor sharedInstance] addDelegate:self];
        
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
        
        [_locationManager startMonitoringSignificantLocationChanges];
        
        [[CCLocationMonitor sharedInstance] addDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [[CCModelChangeMonitor sharedInstance] removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reachable
{
    [self startTimer];
}

- (void)unreachable
{
    [self stopTimer];
}

#pragma mark - NSTimer management

- (void)startTimer
{
    if (_timer == nil) {
        _timer = [NSTimer timerWithTimeInterval:10.0 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}

- (void)stopTimer
{
    [_timer invalidate];
    _timer = nil;
}

#pragma mark - Zone synchronization methods

- (void)performSynchronizationsWithMaxDuration:(NSTimeInterval)maxDuration completionBlock:(void(^)())completionBlock
{
    if ([[CCNetworkHandler sharedInstance] connectionAvailable] == NO || [self lastCoordinateAvailable] == NO)
        return;
    
    NSTimeInterval startSync = [NSDate timeIntervalSinceReferenceDate];
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCList entityName]];
    [fetchRequest setIncludesSubentities:NO];
    NSArray *lists = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error != nil) {
        NSLog(@"%@", error);
        return;
    }
    
    NSMutableArray *listSynchronizationProcessors = [@[] mutableCopy];
    for (CCList *list in lists) {
        CCListSynchronizationProcessor *listSynchronizationProcessor = [[CCListSynchronizationProcessor alloc] initWithList:list coordinates:_lastCoordinate];
        [listSynchronizationProcessors addObject:listSynchronizationProcessor];
    }
    [listSynchronizationProcessors sortUsingComparator:^NSComparisonResult(CCListSynchronizationProcessor *obj1, CCListSynchronizationProcessor *obj2) {
        if (obj1.priority < obj2.priority)
            return NSOrderedAscending;
        else if (obj1.priority > obj2.priority)
            return NSOrderedDescending;
        return NSOrderedSame;
    }];

    __block NSUInteger listSynchronizationProcessorsIndex = 0;
    __block void (^recursiveBlock)();
    recursiveBlock = ^{
        if (listSynchronizationProcessorsIndex == [listSynchronizationProcessors count]) {
            completionBlock();
            dispatch_async(dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                recursiveBlock = nil;
#pragma clang diagnostic pop
            });
            return;
        }
        NSTimeInterval timeElapsed = [NSDate timeIntervalSinceReferenceDate] - startSync;
        if (timeElapsed >= maxDuration) {
            completionBlock();
            return;
        }
        CCListSynchronizationProcessor *listSynchronizationProcessor = listSynchronizationProcessors[listSynchronizationProcessorsIndex];
        [listSynchronizationProcessor.synchronizationAction performSynchronizationWithCompletionBlock:recursiveBlock];
        listSynchronizationProcessorsIndex++;
    };
    recursiveBlock();
}

- (void)performListSynchronization:(CCList *)list completionBlock:(void(^)())completionBlock
{
    __block void(^recursiveBlock)();
    recursiveBlock = ^() {
        CCListSynchronizationProcessor *listSynchronizationProcessor = [[CCListSynchronizationProcessor alloc] initWithList:list coordinates:_lastCoordinate];
        if (listSynchronizationProcessor.synchronizationAction == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                recursiveBlock = nil;
#pragma clang diagnostic pop
            });
            completionBlock();
            return;
        }
        [listSynchronizationProcessor.synchronizationAction performSynchronizationWithCompletionBlock:recursiveBlock];
    };
    recursiveBlock();
}

#pragma mark - timer target

- (void)timerTick:(NSTimer *)timer
{
    [self performSynchronizationsWithMaxDuration:0 completionBlock:^{}];
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

#pragma mark - NSNotificationCenter methods

- (void)reachabilityChanged:(NSNotification *)notification
{
    Reachability *reachability = notification.object;
    if (reachability.isReachable) {
        [self reachable];
    } else {
        [self unreachable];
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
