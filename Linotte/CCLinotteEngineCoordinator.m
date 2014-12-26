//
//  CCLinotteCoordinator.m
//  Linotte
//
//  Created by stant on 15/12/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCLinotteEngineCoordinator.h"

#import <AFNetworking/AFNetworkReachabilityManager.h>
#import <Mixpanel/Mixpanel.h>

#import "CCLinotteAuthenticationManager.h"

#import "CCLinotteAPI.h"

#import "CCNotificationGenerator.h"
#import "CCGeohashMonitor.h"

#import "CCModelChangeHandler.h"
#import "CCSynchronizationHandler.h"

@implementation CCLinotteEngineCoordinator
{
    CCGeohashMonitor *_geohashMonitor;
    CCNotificationGenerator *_notificationGenerator;

    CCModelChangeHandler *_modelChangeHandler;
    CCSynchronizationHandler *_synchronizationHandler;
    
    BOOL _monitoringAndSynchronizationStarted;
    
    NSTimer *_timer;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reachabilityChanged:)
                                                     name:AFNetworkingReachabilityDidChangeNotification
                                                   object:nil];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initializeLinotteEngineWithClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret
{
    _linotteAPI = [[CCLinotteAPI alloc] initWithClientId:clientId clientSecret:clientSecret];
    
    _authenticationManager = [[CCLinotteAuthenticationManager alloc] initWithLinotteAPI:_linotteAPI];
    _authenticationManager.delegate = self;
    
    if (_authenticationManager.readyToSend)
        [self startMonitoringAndSynchronization];
}

- (void)startMonitoringAndSynchronization
{
    if (_monitoringAndSynchronizationStarted)
        return;
    
    _geohashMonitor = [CCGeohashMonitor new];
    _notificationGenerator = [CCNotificationGenerator new];
    _geohashMonitor.delegate = _notificationGenerator;
    
    _modelChangeHandler = [CCModelChangeHandler new];
    _synchronizationHandler = [CCSynchronizationHandler new];
    
    _monitoringAndSynchronizationStarted = YES;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    if (_authenticationManager.needsSync) {
        [_authenticationManager syncWithSuccess:^{
            [_synchronizationHandler performSynchronizationsWithMaxDuration:15 list:nil completionBlock:^(BOOL didSync){
                completionHandler(didSync ? UIBackgroundFetchResultNewData : UIBackgroundFetchResultNoData);
            }];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            CCLog(@"%@", error);
        }];
        return;
    }
    [_synchronizationHandler performSynchronizationsWithMaxDuration:15 list:nil completionBlock:^(BOOL didSync){
        completionHandler(didSync ? UIBackgroundFetchResultNewData : UIBackgroundFetchResultNoData);
    }];
}

- (void)forceListSynchronization:(CCList *)list
{
    if ([self canSend])
        [_synchronizationHandler performSynchronizationsWithMaxDuration:0 list:list completionBlock:^(BOOL didSync) {}];
}

- (BOOL)canSend
{
    return [AFNetworkReachabilityManager sharedManager].isReachable && [_authenticationManager readyToSend];
}

#pragma mark - CCLinotteAuthenticationManagerDelegate methods

- (void)authenticationManager:(CCLinotteAuthenticationManager *)authenticationManager didCreateUserWithAuthMethod:(CCAuthMethod *)authMethod
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    if (mixpanel.distinctId == nil) {
        [mixpanel identify:_authenticationManager.identifier];
        [[mixpanel people] set:@"$created" to:[NSDate date]];
    }
}

- (void)authenticationManagerDidLogin:(CCLinotteAuthenticationManager *)authenticationManager {
    [self startMonitoringAndSynchronization];
}

#pragma mark - NSNotificationCenter methods

- (void)reachabilityChanged:(NSNotification *)notification
{
    if ([AFNetworkReachabilityManager sharedManager].reachable) {
        [self startTimer];
    } else {
        [self stopTimer];
    }
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

#pragma mark - timer target

- (void)timerTick:(NSTimer *)timer
{
    if (_synchronizationHandler.syncing == YES || _authenticationManager.needsCredentials == YES || [AFNetworkReachabilityManager sharedManager].isReachable == NO)
        return;
    if ([_authenticationManager needsSync]) {
        if (_authenticationManager.syncing == YES)
            return;
        
        [_authenticationManager syncWithSuccess:^{
            [_synchronizationHandler performSynchronizationsWithMaxDuration:0 list:nil completionBlock:^(BOOL didSync){}];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if (_authenticationManager.readyToSend)
                [_synchronizationHandler performSynchronizationsWithMaxDuration:0 list:nil completionBlock:^(BOOL didSync){}];
        }];
        return;
    }
    if ([self canSend] == NO)
        return;

    [_synchronizationHandler performSynchronizationsWithMaxDuration:0 list:nil completionBlock:^(BOOL didSync){}];
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
