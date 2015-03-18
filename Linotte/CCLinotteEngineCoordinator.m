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
#import "CCOldLinotteMigration.h"
#import "CCCurrentUserData.h"

#import "CCLinotteAPI.h"
#import "CCLinotteCoreDataStack.h"
#import "CCNetworkLogs.h"

#import "CCNotificationGenerator.h"
#import "CCGeohashMonitor.h"

#import "CCModelChangeHandler.h"
#import "CCSynchronizationHandler.h"

#import "CCAddListCommand.h"

#import "CCAddress.h"
#import "CCAuthMethod.h"

@implementation CCLinotteEngineCoordinator
{
    CCGeohashMonitor *_geohashMonitor;
    CCNotificationGenerator *_notificationGenerator;

    CCModelChangeHandler *_modelChangeHandler;
    CCSynchronizationHandler *_synchronizationHandler;
    
    BOOL _notifyingStarted;
    BOOL _synchronizationStarted;
    
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
    
    if (_authenticationManager.readyToSend) {
        [self startSynchronization];
        
        NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
        if ([CCAddress numberOfNotifyingAddressesInManagedObjectContext:managedObjectContext] > 0)
            [self startNotifying];
        
        [CCOldLinotteMigration migrateIfNeeded];
    }
}

- (void)startSynchronization
{
    if (_synchronizationStarted)
        return;

    _modelChangeHandler = [CCModelChangeHandler new];
    _synchronizationHandler = [CCSynchronizationHandler new];
    
    _synchronizationStarted = YES;
}

- (void)startNotifying
{
    if (_notifyingStarted)
        return;
    
    _geohashMonitor = [CCGeohashMonitor new];
    _notificationGenerator = [CCNotificationGenerator new];
    _geohashMonitor.delegate = _notificationGenerator;
    
    _notifyingStarted = YES;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    if (_authenticationManager.needsSync) {
        [_authenticationManager syncWithSuccess:^{
            [_synchronizationHandler performSynchronizationsWithMaxDuration:15 list:nil completionBlock:^(BOOL didSync){
                completionHandler(didSync ? UIBackgroundFetchResultNewData : UIBackgroundFetchResultNoData);
            }];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            completionHandler(UIBackgroundFetchResultNoData);
            CCLog(@"%@", error);
        }];
        return;
    }
    [_synchronizationHandler performSynchronizationsWithMaxDuration:15 list:nil completionBlock:^(BOOL didSync){
        completionHandler(didSync ? UIBackgroundFetchResultNewData : UIBackgroundFetchResultNoData);
    }];
}

- (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
{
    if (![[url scheme] isEqualToString:@"comlinotte"])
        return NO;
    
    NSString *commandLine = [NSString stringWithFormat:@"%@%@/", [url host], [url relativePath]];
    
    if (commandLine == nil)
        return NO;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ MATCHES match", commandLine];
    NSArray *commands = @[[CCAddListCommand new]];
    
    id<CCLinotteUrlCommand> command = [[commands filteredArrayUsingPredicate:predicate] firstObject];
    
    if (command == nil)
        return NO;
    
    NSArray *args = [commandLine componentsSeparatedByString:@"/"];
    [command execute:args];
    
    NSLog(@"%@ %@", url, sourceApplication);
    return YES;
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

- (void)authenticationManager:(CCLinotteAuthenticationManager *)authenticationManager didCreateDeviceWithIdentifier:(NSString *)identifier
{
    [CCNetworkLogs sharedInstance].identifier = identifier;
}

- (void)authenticationManager:(CCLinotteAuthenticationManager *)authenticationManager didCreateUserWithAuthMethod:(CCAuthMethod *)authMethod
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    if (mixpanel.distinctId == nil) {
        [mixpanel identify:_authenticationManager.identifier];
        [[mixpanel people] set:@"$created" to:[NSDate date]];
    }
}

- (void)authenticationManagerDidLogin:(CCLinotteAuthenticationManager *)authenticationManager {
    [self startSynchronization];
    [CCOldLinotteMigration migrateIfNeeded];
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
        dispatch_async(dispatch_get_main_queue(), ^{
            [self timerTick:_timer];
        });
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

- (void)totallyKillCurrentSession
{
    [CCUD totallyKillCurrentSession];
    [self.authenticationManager logout];
    [[CCLinotteCoreDataStack sharedInstance] totallyKillCurrentSession];
    abort();
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
