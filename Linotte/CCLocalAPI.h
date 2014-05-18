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

@interface CCLocalAPI : NSObject

- (void)setClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret;

- (void)authenticate:(NSString *)username password:(NSString *)password completionBlock:(void(^)(bool success))completionBlock;
- (void)refreshTokenWithCompletionBlock:(void(^)(bool success))completionBlock;
- (BOOL)isLoggedIn;

- (void)createAndAuthenticateAnonymousUserWithCompletionBlock:(void(^)(bool success))completionBlock;

- (void)sendAddress:(CCAddress *)address completionBlock:(void(^)(bool success))completionBlock;

+ (instancetype)sharedInstance;

@end
