//
//  CCLinotteCoordinator.h
//  Linotte
//
//  Created by stant on 15/12/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CCLinotteAuthenticationManagerDelegate.h"

@class CCLinotteAPI;
@class CCLinotteAuthenticationManager;
@class CCList;

#define CCLEC [CCLinotteEngineCoordinator sharedInstance]

@interface CCLinotteEngineCoordinator : NSObject<CCLinotteAuthenticationManagerDelegate>

@property(nonatomic, readonly)CCLinotteAPI *linotteAPI;
@property(nonatomic, readonly)CCLinotteAuthenticationManager *authenticationManager;

- (void)initializeLinotteEngineWithClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret;
- (void)startNotifying;
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;
- (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

- (void)forceListSynchronization:(CCList *)list;

+ (instancetype)sharedInstance;

@end
