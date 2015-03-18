//
//  CCLinotteCredentialStore.h
//  Linotte
//
//  Created by stant on 17/12/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <FacebookSDK/FacebookSDK.h>

typedef enum : NSUInteger {
    kCCFirstStart = 0, // When nothing has happened yet
    kCCLoggedIn, // When everything is fine
    kCCCreateDeviceId, // When device is not created yet
    kCCSendAuthMethod, // When there are pending social account
    kCCSendPushNotificationDeviceToken // When push notification token needs to be sent
} CCCredentialStoreState;

@class CCAuthMethod;
@class CCLinotteAPI;

@interface CCLinotteCredentialStore : NSObject

@property(nonatomic, strong)NSString *accessToken;
@property(nonatomic, strong)NSString *identifier;
@property(nonatomic, strong)NSString *deviceId;
@property(nonatomic, readonly)CCCredentialStoreState storeState;

- (id)initWithLinotteAPI:(CCLinotteAPI *)linotteAPI;

- (CCAuthMethod *)addAuthMethodWithEmail:(NSString *)email password:(NSString *)password;
- (CCAuthMethod *)addAuthMethodWithFacebookAccount:(id<FBGraphUser>)user;
- (BOOL)hasAuthMethodToSend;
- (CCAuthMethod *)nextUnsentAuthMethod;
- (void)logout;

@end
