//
//  CCAdRemSDK.h
//  AdRem
//
//  Created by stant on 13/04/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCAddress;
@class CCList;
@class RKPaginator;

typedef enum : NSUInteger {
    kCCFirstStart, // When nothing has happened yet
    kCCLoggedIn, // When everything is fine
    kCCRequestRefreshToken, // When access token is outdated
    kCCCreateDeviceId, // When upgrading from 1.0 to 2.0, device is not created yet
    kCCFailed, // unknown error
} CCLoggedState;

@interface CCLinotteAPI : NSObject

@property(nonatomic, strong)NSString *identifier;
@property(nonatomic, readonly)CCLoggedState loggedState;

- (void)setClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret;

- (void)APIIinitialization:(void(^)(CCLoggedState fromState))stateStepBlock completionBock:(void(^)(BOOL success))completionBlock;

- (void)authenticate:(NSString *)username password:(NSString *)password completionBlock:(void(^)(BOOL success))completionBlock;
- (void)refreshTokenWithCompletionBlock:(void(^)(BOOL success))completionBlock;

- (void)createAndAuthenticateAnonymousUserWithCompletionBlock:(void(^)(BOOL success))completionBlock;

- (void)createAddress:(CCAddress *)address completionBlock:(void(^)(BOOL success))completionBlock;
- (void)createList:(CCList *)list completionBlock:(void(^)(BOOL success))completionBlock;

- (void)removeList:(NSString *)identifier completionBlock:(void(^)(BOOL success))completionBlock;
- (void)removeAddress:(NSString *)identifier completionBlock:(void(^)(BOOL success))completionBlock;

- (void)addAddress:(CCAddress *)address toList:(CCList *)list completionBlock:(void(^)(BOOL success))completionBlock;
- (void)removeAddress:(CCAddress *)address fromList:(CCList *)list completionBlock:(void(^)(BOOL success))completionBlock;

- (void)updateAddress:(CCAddress *)address completionBlock:(void(^)(BOOL success))completionBlock;
- (void)updateList:(CCList *)list completionBlock:(void(^)(BOOL success))completionBlock;

- (void)updateAddressUserData:(CCAddress *)address completionBlock:(void(^)(BOOL success))completionBlock;

+ (instancetype)sharedInstance;

@end
