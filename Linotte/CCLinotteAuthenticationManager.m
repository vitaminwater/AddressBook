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

#import "NSData+HexString.h"

#import "CCCurrentUserData.h"
#import "CCLinotteAPI.h"
#import "CCLinotteCoreDataStack.h"

#import "CCAuthMethod.h"

#import "CCLinotteCredentialStore.h"


@interface CCLinotteAuthenticationManager()

@property(nonatomic, assign)BOOL syncing;

@end

@implementation CCLinotteAuthenticationManager
{
    CCLinotteAPI *_linotteAPI;
    
    CCLinotteCredentialStore *_credentialStore;
}

@dynamic needsCredentials, needsSync, readyToSend;
@dynamic identifier, deviceId;

- (id)initWithLinotteAPI:(CCLinotteAPI *)linotteAPI
{
    self = [super init];
    if (self) {
        _linotteAPI = linotteAPI;

        _credentialStore = [[CCLinotteCredentialStore alloc] initWithLinotteAPI:_linotteAPI];
        
        if (_credentialStore.accessToken != nil) {
            [_linotteAPI setAuthHTTPHeader:_credentialStore.accessToken];
            if (_credentialStore.deviceId != nil) {
                [_linotteAPI setDeviceHTTPHeader:_credentialStore.deviceId];
            }
        }
    }
    return self;
}

- (BOOL)needsCredentials
{
    return _credentialStore.accessToken == nil;
}

- (BOOL)needsSync
{
    NSArray *doesntNeedSync = @[@(kCCLoggedIn), @(kCCFirstStart)];
    return [doesntNeedSync containsObject:@(_credentialStore.storeState)] == NO;
}

- (BOOL)readyToSend
{
    NSArray *readyToSend = @[@(kCCSendAuthMethod), @(kCCLoggedIn)];
    return [readyToSend containsObject:@(_credentialStore.storeState)];
}

#pragma mark - API initialization method

- (void)syncWithSuccess:(void(^)())successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    CCCredentialStoreState storeState = _credentialStore.storeState;
    __weak typeof(self) weakSelf = self;
    _syncing = YES;
    switch (storeState) {
        case kCCFirstStart: {
            dispatch_async(dispatch_get_main_queue(), ^{
                successBlock();
                weakSelf.syncing = NO;
            });
            break;
        }
        case kCCCreateDeviceId: {
            [_linotteAPI createDeviceWithSuccess:^(NSString *deviceId) {
                _credentialStore.deviceId = deviceId;
                [_delegate authenticationManager:self didCreateDeviceWithIdentifier:deviceId];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf syncWithSuccess:successBlock failure:failureBlock];
                });
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                weakSelf.syncing = NO;
                failureBlock(task, error);
            }];
            break;
        }
        case kCCSendAuthMethod: {
            CCAuthMethod *authMethod = [_credentialStore nextUnsentAuthMethod];
            
            NSDictionary *parameters = [authMethod requestDict];
            if (parameters == nil) {
                [[CCLinotteCoreDataStack sharedInstance] delete:authMethod];
                return;
            }
            
            [_linotteAPI addAuthenticationMethod:parameters success:^(NSString *identifier) {
                authMethod.identifier = identifier;
                authMethod.sentValue = YES;
                [[CCLinotteCoreDataStack sharedInstance] saveContext];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf syncWithSuccess:successBlock failure:failureBlock];
                });
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                weakSelf.syncing = NO;
                failureBlock(task, error);
            }];
            break;
        }
        case kCCSendPushNotificationDeviceToken: {
            NSString *pushNotificationDeviceToken = [CCUD.pushNotificationDeviceToken hexString];
            [_linotteAPI sendDevicePushNotificationToken:pushNotificationDeviceToken success:^{
                CCUD.pushNotificationDeviceTokenSent = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf syncWithSuccess:successBlock failure:failureBlock];
                });
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                weakSelf.syncing = NO;
                failureBlock(task, error);
            }];
        }
        case kCCLoggedIn: {
            dispatch_async(dispatch_get_main_queue(), ^{
                successBlock();
                weakSelf.syncing = NO;
            });
            break;
        }
    }
}

- (CCAuthMethod *)addAuthMethodWithEmail:(NSString *)email password:(NSString *)password
{
    return [_credentialStore addAuthMethodWithEmail:email password:password];
}

- (CCAuthMethod *)addAuthMethodWithFacebookAccount:(id<FBGraphUser>)user
{
    return [_credentialStore addAuthMethodWithFacebookAccount:user];
}

- (void)createAccountOrLoginWithAuthMethod:(CCAuthMethod *)authMethod success:(void(^)())successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    [self authenticateWithAuthMethod:authMethod success:successBlock failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self createUserWithAuthMethod:authMethod success:successBlock failure:failureBlock];
    }];
}

- (void)authenticateWithAuthMethod:(CCAuthMethod *)authMethod success:(void(^)())successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSDictionary *parameters = [authMethod requestDict];
    [_linotteAPI authenticate:parameters success:^(NSString *identifier, NSString *accessToken, NSString *authMethodIdentifier) {
        _credentialStore.accessToken = accessToken;
        _credentialStore.identifier = identifier;
        authMethod.identifier = authMethodIdentifier;
        authMethod.sentValue = YES;
        [[CCLinotteCoreDataStack sharedInstance] saveContext];
        [_delegate authenticationManagerDidLogin:self];
        [[NSNotificationCenter defaultCenter] postNotificationName:kCCLinotteAuthenticationManagerDidLogin object:@{kCCLinotteAuthenticationManagerUser : self}];
        successBlock();
    } failure:failureBlock];
}

- (void)createUserWithAuthMethod:(CCAuthMethod *)authMethod success:(void(^)())successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSDictionary *parameters = [authMethod requestDict];
    [_linotteAPI createUser:parameters success:^(NSString *identifier, NSString *accessToken, NSString *authMethodIdentifier) {
        _credentialStore.accessToken = accessToken;
        _credentialStore.identifier = identifier;
        authMethod.identifier = authMethodIdentifier;
        authMethod.sentValue = YES;
        [[CCLinotteCoreDataStack sharedInstance] saveContext];
        [_delegate authenticationManager:self didCreateUserWithAuthMethod:authMethod];
        [_delegate authenticationManagerDidLogin:self];
        [[NSNotificationCenter defaultCenter] postNotificationName:kCCLinotteAuthenticationManagerDidCreateUser object:@{kCCLinotteAuthenticationManagerUser : self, kCCLinotteAuthenticationManagerAuthMethod : authMethod, kCCLinotteAuthenticationManagerUserIdentifier : identifier}];
        successBlock();
    } failure:failureBlock];
}

#pragma mark - getter methods

- (NSString *)identifier
{
    return _credentialStore.identifier;
}

- (NSString *)deviceId
{
    return _credentialStore.deviceId;
}

#pragma mark - tokens storage

- (void)logout
{
    [_credentialStore logout];
    
    [_linotteAPI unsetAuthHttpHeader];
    [_linotteAPI unsetDeviceHTTPHeader];
}

@end
