//
//  CCAuthenticationManager.h
//  Linotte
//
//  Created by stant on 15/12/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <FacebookSDK/FacebookSDK.h>

#import "CCLinotteAuthenticationManagerDelegate.h"

#define kCCLinotteAuthenticationManagerDidCreateUser @"kCCLinotteAuthenticationManagerDidCreateUser"
#define kCCLinotteAuthenticationManagerAuthMethod @"kCCLinotteAuthenticationManagerAuthMethod"
#define kCCLinotteAuthenticationManagerUserIdentifier @"kCCLinotteAuthenticationManagerUserIdentifier"

#define kCCLinotteAuthenticationManagerDidLogin @"kCCLinotteAuthenticationManagerDidLogin"

#define kCCLinotteAuthenticationManagerUser @"kCCLinotteAuthenticationManagerUser"


@class CCLinotteAPI;

@interface CCLinotteAuthenticationManager : NSObject

@property(nonatomic, weak)id<CCLinotteAuthenticationManagerDelegate> delegate;

@property(nonatomic, readonly)BOOL needsCredentials;
@property(nonatomic, readonly)BOOL needsSync;
@property(nonatomic, readonly)BOOL syncing;
@property(nonatomic, readonly)BOOL readyToSend;
@property(nonatomic, readonly)NSString *identifier;

- (id)initWithLinotteAPI:(CCLinotteAPI *)linotteAPI;

- (void)addAuthMethodWithEmail:(NSString *)email password:(NSString *)password;
- (void)addAuthMethodWithFacebookAccount:(id<FBGraphUser>)user;
- (void)createAccountOrLoginWithSuccess:(void(^)())successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock;

- (void)syncWithSuccess:(void(^)())successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock;

@end
