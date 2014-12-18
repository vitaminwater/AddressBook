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
#define kCCLinotteAuthenticationManagerUserEmail @"kCCLinotteAuthenticationManagerUserEmail"
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

- (id)initWithLinotteAPI:(CCLinotteAPI *)linotteAPI;

- (BOOL)needsCredentials;
- (BOOL)needsSync;
- (BOOL)readyToSend;

- (void)setCredentials:(NSString *)email password:(NSString *)password;
- (void)associateFacebookAccount:(id<FBGraphUser>)user;

- (void)syncWithSuccess:(void(^)())successBlock failure:(void(^)(NSError *error))failureBlock;

@end
