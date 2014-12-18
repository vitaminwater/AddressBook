//
//  CCAuthenticationManager.m
//  Linotte
//
//  Created by stant on 15/12/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCLinotteAuthenticationManager.h"

#import <SSKeychain/SSKeychain.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>

#import "CCLinotteAPI.h"
#import "CCLinotteCoreDataStack.h"

#import "CCSocialAccount.h"

#import "CCLinotteCredentialStore.h"


@implementation CCLinotteAuthenticationManager
{
    CCLinotteAPI *_linotteAPI;
    
    CCLinotteCredentialStore *_credentialStore;
}

@dynamic needsCredentials, needsSync, readyToSend;

- (id)initWithLinotteAPI:(CCLinotteAPI *)linotteAPI
{
    self = [super init];
    if (self) {
        _linotteAPI = linotteAPI;

        if (_credentialStore.accessToken != nil) {
            [_linotteAPI setOAuth2HTTPHeader:_credentialStore.accessToken];
            if (_credentialStore.deviceId != nil) {
                [_linotteAPI setDeviceHTTPHeader:_credentialStore.deviceId];
            }
        }
    }
    return self;
}

- (BOOL)needsCredentials
{
    return _credentialStore.email == nil;
}

- (BOOL)needsSync
{
    NSArray *doesntNeedSync = @[@(kCCLoggedIn), @(kCCFirstStart)];
    return [doesntNeedSync containsObject:@(_credentialStore.storeState)] == NO;
}

- (BOOL)readyToSend
{
    NSArray *readyToSend = @[@(kCCAssociateSocialAccount), @(kCCLoggedIn)];
    return [readyToSend containsObject:@(_credentialStore.storeState)];
}

#pragma mark - API initialization method

- (void)syncWithSuccess:(void(^)())successBlock failure:(void(^)(NSError *error))failureBlock
{
    CCCredentialStoreState storeState = _credentialStore.storeState;
    _syncing = YES;
    switch (storeState) {
        case kCCFirstStart: {
            successBlock();
            break;
        }
        case kCCCreateAccount: {
            NSDictionary *parameters = @{@"email" : _credentialStore.email, @"password" : _credentialStore.password};
            [_linotteAPI createUser:parameters success:^(NSString *identifier) {
                _credentialStore.identifer = identifier;
                [_delegate authenticationManager:self didCreateUserWithEmail:_credentialStore.email identifier:identifier];
                [[NSNotificationCenter defaultCenter] postNotificationName:kCCLinotteAuthenticationManagerDidCreateUser object:@{kCCLinotteAuthenticationManagerUser : self, kCCLinotteAuthenticationManagerUserEmail : _credentialStore.email, kCCLinotteAuthenticationManagerUserIdentifier : identifier}];
                [self syncWithSuccess:successBlock failure:failureBlock];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                failureBlock(error);
            }];
            break;
        }
        case kCCAuthenticate: {
            [_linotteAPI authenticate:_credentialStore.email password:_credentialStore.password success:^(NSString *accessToken, NSString *refreshToken, NSUInteger expiresIn) {
                [self saveTokens:accessToken refreshToken:refreshToken expiresInTimeStamp:expiresIn];
                [_delegate authenticationManagerDidLogin:self];
                [[NSNotificationCenter defaultCenter] postNotificationName:kCCLinotteAuthenticationManagerDidLogin object:@{kCCLinotteAuthenticationManagerUser : self}];
                [self syncWithSuccess:successBlock failure:failureBlock];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                failureBlock(error);
            }];
            break;
        }
        case kCCRequestRefreshToken: {
            [_linotteAPI refreshToken:_credentialStore.refreshToken success:^(NSString *accessToken, NSString *refreshToken, NSUInteger expiresIn) {
                [self saveTokens:accessToken refreshToken:refreshToken expiresInTimeStamp:expiresIn];
                [self syncWithSuccess:successBlock failure:failureBlock];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                failureBlock(error);
            }];
            break;
        }
        case kCCCreateDeviceId: {
            [_linotteAPI createDeviceWithSuccess:^(NSString *deviceId) {
                [self saveDeviceId:deviceId];
                [self syncWithSuccess:successBlock failure:failureBlock];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                failureBlock(error);
            }];
            break;
        }
        case kCCAssociateSocialAccount: {
            CCSocialAccount *socialAccount = [_credentialStore nextSocialAccountToSend];
            NSString *expirationDateString = [_linotteAPI stringFromDate:socialAccount.expirationDate];
            NSDictionary *parameters = @{@"social_media_identifier" : socialAccount.mediaIdentifier, @"social_identifier" : socialAccount.socialIdentifier, @"oauth_token" : socialAccount.authToken, @"refresh_token" : socialAccount.refreshToken, @"expiration_date" : expirationDateString};
            [_linotteAPI associateWithSocialAccount:parameters success:^(NSString *identifier) {
                socialAccount.identifier = identifier;
                [[CCLinotteCoreDataStack sharedInstance] saveContext];
                [self syncWithSuccess:successBlock failure:failureBlock];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                failureBlock(error);
            }];
            break;
        }
        case kCCLoggedIn: {
            dispatch_async(dispatch_get_main_queue(), ^{
                successBlock();
                _syncing = NO;
            });
            break;
        }
    }
}

- (void)setCredentials:(NSString *)email password:(NSString *)password
{
    _credentialStore.email = email;
    _credentialStore.password = password;
    if ([AFNetworkReachabilityManager sharedManager].isReachable == NO)
        return;
    [_linotteAPI authenticate:email password:password success:^(NSString *accessToken, NSString *refreshToken, NSUInteger expiresIn) {
        [self saveTokens:accessToken refreshToken:refreshToken expiresInTimeStamp:expiresIn];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
}

- (void)associateFacebookAccount:(id<FBGraphUser>)user
{
    [_credentialStore addFacebookAccount:user];
}

#pragma mark - tokens storage

- (void)saveTokens:(NSString *)accessToken refreshToken:(NSString *)refreshToken expiresInTimeStamp:(NSUInteger)expiresInTimeStamp
{
    NSDate *expirationDate = [[NSDate date] dateByAddingTimeInterval:expiresInTimeStamp];
    
    _credentialStore.accessToken = accessToken;
    _credentialStore.refreshToken = refreshToken;
    _credentialStore.expirationDate = expirationDate;
    [_linotteAPI setOAuth2HTTPHeader:_credentialStore.accessToken];
}

- (void)saveDeviceId:(NSString *)deviceId
{
    _credentialStore.deviceId = deviceId;
    [_linotteAPI setDeviceHTTPHeader:deviceId];
}

- (void)logout
{
    [_credentialStore logout];
    
    [_linotteAPI unsetOAuth2HttpHeader];
    [_linotteAPI unsetDeviceHTTPHeader];
}

@end
