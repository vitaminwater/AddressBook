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
    kCCFirstStart, // When nothing has happened yet
    kCCLoggedIn, // When everything is fine
    kCCRequestRefreshToken, // When access token is outdated
    kCCCreateDeviceId, // When device is not created yet
    kCCCreateAccount, // When credentials have been provided but accounts still not created
    kCCAssociateSocialAccount, // When there are pending social account
    kCCAuthenticate, // User has been created, but user not logged in
} CCCredentialStoreState;

@class CCSocialAccount;

@interface CCLinotteCredentialStore : NSObject

@property(nonatomic, strong)NSString *accessToken;
@property(nonatomic, strong)NSString *refreshToken;
@property(nonatomic, strong)NSDate *expirationDate;

@property(nonatomic, strong)NSString *deviceId;

@property(nonatomic, strong)NSString *identifer;
@property(nonatomic, strong)NSString *email;
@property(nonatomic, strong)NSString *password;

@property(nonatomic, readonly)CCCredentialStoreState storeState;

- (void)addFacebookAccount:(id<FBGraphUser>)user;
- (BOOL)hasSocialAccountToSend;
- (CCSocialAccount *)nextSocialAccountToSend;
- (void)logout;

@end
