//
//  CCAdRemSDK.h
//  AdRem
//
//  Created by stant on 13/04/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCAddress;
@class RKPaginator;

typedef enum : NSUInteger {
    kCCFirstStart, // When nothing has happened yet
    kCCRequestRefreshToken, // When access token is outdated
    kCCLoggedIn, // When everything is fine
    kCCRequestIdentifierSync, // When identifier is missing (upgrade purpose)
    kCCRequestTotalResync, // When application is outsynced and we need to create a brand new user... this is bad
    kCCFailed, // unknown error
} CCLoggedState;

@interface CCLocalAPI : NSObject

@property(nonatomic, strong)NSString *identifier;
@property(nonatomic, readonly)CCLoggedState loggedState;

- (void)setClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret;

- (void)APIIinitialization:(void(^)(BOOL newUserCreated))completionBlock;

- (void)authenticate:(NSString *)username password:(NSString *)password completionBlock:(void(^)(BOOL success))completionBlock;
- (void)refreshTokenWithCompletionBlock:(void(^)(BOOL success))completionBlock;

- (void)createAndAuthenticateAnonymousUserWithCompletionBlock:(void(^)(BOOL success, NSString *identifier))completionBlock;
- (void)fetchIdentifier:(void(^)(BOOL success, NSString *identifier))completionBlock;

- (void)sendAddress:(CCAddress *)address completionBlock:(void(^)(BOOL success))completionBlock;

+ (instancetype)sharedInstance;

@end
