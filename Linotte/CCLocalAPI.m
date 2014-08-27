//
//  CCLocalSDK.m
//  Local
//
//  Created by stant on 13/04/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCLocalAPI.h"

#import <SSKeychain/SSKeychain.h>

#import "CCRestKit.h"

#import "CCOAuthTokenResponse.h"
#import "CCOAuthTokenRequest.h"

#import "CCUserPostPutResponse.h"
#import "CCUserPostPutRequest.h"

#import "CCAddress.h"

// SSKeychain accounts
#if defined(DEBUG)
#define kCCKeyChainServiceName @"kCCKeyChainServiceNameDebug9"
#define kCCAccessTokenAccountName @"kCCAccessTokenAccountNameDebug"
#define kCCRefreshTokenAccountName @"kCCRefreshTokenAccountNameDebug"
#define kCCExpireTimeStampAccountName @"kCCExpireTimeStampAccountNameDebug"
#define kCCUserIdentifierAccountName @"kCCUserIdentifierAccountNameDebug"
#else
#define kCCKeyChainServiceName @"kCCKeyChainServiceName3"
#define kCCAccessTokenAccountName @"kCCAccessTokenAccountName"
#define kCCRefreshTokenAccountName @"kCCRefreshTokenAccountName"
#define kCCExpireTimeStampAccountName @"kCCExpireTimeStampAccountName"
#define kCCUserIdentifierAccountName @"kCCUserIdentifierAccountName"
#endif

// NSUserDefaults keys
#define kCCAlreadyChecked403 @"kCCAlreadyChecked403"

@interface CCLocalAPI()
{
    NSString *_clientId;
    NSString *_clientSecret;
    
    NSString *_accessToken;
    NSString *_refreshToken;
    NSString *_expireTimeStamp;
}

@end

@implementation CCLocalAPI

- (id)init
{
    self = [super init];
    if (self != nil) {
        [SSKeychain setAccessibilityType:kSecAttrAccessibleAfterFirstUnlock];
        _accessToken = [SSKeychain passwordForService:kCCKeyChainServiceName account:kCCAccessTokenAccountName];
        _refreshToken = [SSKeychain passwordForService:kCCKeyChainServiceName account:kCCRefreshTokenAccountName];
        _identifier = [SSKeychain passwordForService:kCCKeyChainServiceName account:kCCUserIdentifierAccountName];
        _expireTimeStamp = [SSKeychain passwordForService:kCCKeyChainServiceName account:kCCExpireTimeStampAccountName];
        [self refreshLoggedState];
        [self setOAuth2HTTPHeader];
    }
    return self;
}

- (void)refreshLoggedState
{
    if ([self isFirstStart])
        _loggedState = kCCFirstStart;
    else if (!_expireTimeStamp || [_expireTimeStamp integerValue] - 60 * 60 * 24 < [[NSDate date] timeIntervalSince1970])
        _loggedState = kCCRequestRefreshToken;
    else if (!_identifier)
        _loggedState = kCCRequestIdentifierSync;
    else
        _loggedState = kCCLoggedIn;
}

- (BOOL)isFirstStart
{
    return ![[SSKeychain accountsForService:kCCKeyChainServiceName] count];
}

#pragma mark - API initialization method

- (void)APIIinitialization:(void(^)(BOOL newUserCreated))completionBlock
{
    //BOOL ckecked403 = [[NSUserDefaults standardUserDefaults] boolForKey:kCCAlreadyChecked403];
    if (_loggedState == kCCFirstStart) {
        [self createAndAuthenticateAnonymousUserWithCompletionBlock:^(BOOL success, NSString *identifier) {
            _loggedState = success ? kCCLoggedIn : kCCFailed;
            completionBlock(YES);
        }];
    } else if (_loggedState == kCCRequestRefreshToken) {
        [self refreshTokenWithCompletionBlock:^(BOOL success) {
            if (success) {
                [self refreshLoggedState];
                [self APIIinitialization:completionBlock];
                return;
            }
            _loggedState = kCCFailed;
            completionBlock(NO);
        }];
    } else if (_loggedState == kCCRequestIdentifierSync) {
        [self fetchIdentifier:^(BOOL success, NSString *identifier) {
            if (success) {
                [self refreshLoggedState];
                [self APIIinitialization:completionBlock];
                return;
            }
            _loggedState = kCCFailed;
            completionBlock(NO);
        }];
    } else if (_loggedState == kCCLoggedIn) {
        completionBlock(NO);
    }
}

#pragma mark - OAuth2 credentials

- (void)setClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret
{
    _clientId = clientId;
    _clientSecret = clientSecret;
}

- (void)setOAuth2HTTPHeader
{
    RKObjectManager *objectManager = [CCRestKit getObjectManager:kCCLocalJSONObjectManager];
    
    NSString *oauth2Header = [NSString stringWithFormat:@"Bearer %@", _accessToken];
    [objectManager.HTTPClient setDefaultHeader:@"Authorization" value:oauth2Header];
}

#pragma mark - Authentication methods

- (void)authenticate:(NSString *)username password:(NSString *)password completionBlock:(void(^)(BOOL success))completionBlock
{
    NSAssert(_clientId != nil && _clientSecret != nil, @"ClientId and/or clientSecret not set !");
    RKObjectManager *objectManager = [CCRestKit getObjectManager:kCCLocalUrlEncodedObjectManager];
    
    CCOAuthTokenRequest *oauthTokenRequest = [self createOauthTokenRequest];
    oauthTokenRequest.grantType = @"password";
    oauthTokenRequest.username = username;
    oauthTokenRequest.password = password;
    
    [objectManager postObject:oauthTokenRequest path:kCCLocalAPIAccessToken parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        CCOAuthTokenResponse *oauthTokenResponse = mappingResult.firstObject;
        [self saveTokens:oauthTokenResponse];
        completionBlock(YES);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        completionBlock(NO);
    }];
}

- (void)refreshTokenWithCompletionBlock:(void(^)(BOOL success))completionBlock
{
    NSAssert(_clientId != nil && _clientSecret != nil, @"ClientId and/or clientSecret not set !");
    NSAssert(_refreshToken != nil, @"Refresh token not set !");
    RKObjectManager *objectManager = [CCRestKit getObjectManager:kCCLocalUrlEncodedObjectManager];
    
    CCOAuthTokenRequest *oauthTokenRequest = [self createOauthTokenRequest];
    oauthTokenRequest.grantType = @"refresh_token";
    oauthTokenRequest.refreshToken = _refreshToken;
    
    [objectManager postObject:oauthTokenRequest path:kCCLocalAPIAccessToken parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        CCOAuthTokenResponse *oauthTokenResponse = mappingResult.firstObject;
        [self saveTokens:oauthTokenResponse];
        completionBlock(YES);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        completionBlock(NO);
    }];
}

- (void)saveTokens:(CCOAuthTokenResponse *)tokenResponse
{
    NSError *error;
    
    _accessToken = tokenResponse.accessToken;
    _refreshToken = tokenResponse.refreshToken;
    _expireTimeStamp = tokenResponse.expireTimeStampString;
    if ([SSKeychain setPassword:_accessToken forService:kCCKeyChainServiceName account:kCCAccessTokenAccountName error:&error] == NO) {
        NSLog(@"%@", error);
    }
    
    if ([SSKeychain setPassword:_refreshToken forService:kCCKeyChainServiceName account:kCCRefreshTokenAccountName error:&error] == NO) {
        NSLog(@"%@", error);
    }
    
    if ([SSKeychain setPassword:_expireTimeStamp forService:kCCKeyChainServiceName account:kCCExpireTimeStampAccountName error:&error] == NO) {
        NSLog(@"%@", error);
    }
    [self setOAuth2HTTPHeader];
}

- (CCOAuthTokenRequest *)createOauthTokenRequest
{
    CCOAuthTokenRequest *oauthTokenRequest = [CCOAuthTokenRequest new];
    oauthTokenRequest.clientId = _clientId;
    oauthTokenRequest.clientSecret = _clientSecret;
    oauthTokenRequest.scope = @"read+write";
    return oauthTokenRequest;
}

#pragma mark - User methods

- (void)createAndAuthenticateAnonymousUserWithCompletionBlock:(void(^)(BOOL success, NSString *identifier))completionBlock
{
    NSAssert(_clientId != nil && _clientSecret != nil, @"ClientId and/or clientSecret not set !");
    RKObjectManager *objectManager = [CCRestKit getObjectManager:kCCLocalJSONObjectManager];
    
    CCUserPostPutRequest *postPutRequest = [CCUserPostPutRequest new];
    postPutRequest.username = [[[NSUUID UUID] UUIDString] substringToIndex:30];
    postPutRequest.password = [[NSUUID UUID] UUIDString];
    postPutRequest.firstName = [[[NSUUID UUID] UUIDString] substringToIndex:30];
    postPutRequest.lastName = [[[NSUUID UUID] UUIDString] substringToIndex:30];
    postPutRequest.email = [NSString stringWithFormat:@"%@@getcairnsapp.com", [[NSUUID UUID] UUIDString]];
    postPutRequest.isNewUser = @YES; // TODO: remove when db clean
    
    [objectManager postObject:postPutRequest path:kCCLocalAPIUser parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        CCUserPostPutResponse *response = [mappingResult firstObject];
        [self saveUserIdentifier:response.identifier];
        [self authenticate:postPutRequest.username password:postPutRequest.password completionBlock:^(BOOL success) {
            completionBlock(success, response.identifier);
        }];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        completionBlock(NO, nil);
    }];
}

- (void)saveUserIdentifier:(NSString *)identifier {
    NSError *error;
    if ([SSKeychain setPassword:identifier forService:kCCKeyChainServiceName account:kCCUserIdentifierAccountName error:&error] == NO) {
        NSLog(@"%@", error);
    }
    _identifier = identifier;
}

#pragma mark - Notes methods

- (void)sendAddress:(CCAddress *)address completionBlock:(void(^)(BOOL success))completionBlock
{
    RKObjectManager *objectManager = [CCRestKit getObjectManager:kCCLocalJSONObjectManager];
    
    if (address.identifier != nil) {
        NSLog(@"Sending address: %@ %@ %@", address.name, address.provider, address.providerId);
        [objectManager postObject:address path:kCCLocalAPIAddress parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            completionBlock(YES);
            NSLog(@"Adresse %@ sent..", address.name);
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            completionBlock(NO);
            NSLog(@"Adresse %@ error..", address.name);
        }];
    }
}

#pragma mark - recovery methods
// TODO: following methods provide a way to recover old version to a stable state. Remove when unneeded

- (void)fetchIdentifier:(void(^)(BOOL success, NSString *identifier))completionBlock {
    NSAssert(_clientId != nil && _clientSecret != nil, @"ClientId and/or clientSecret not set !");
    RKObjectManager *objectManager = [CCRestKit getObjectManager:kCCLocalJSONObjectManager];
    
    AFHTTPClient *client = objectManager.HTTPClient;
    [client getPath:[NSString stringWithFormat:@"%@me/", kCCLocalAPIUser] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // NSLog(@"%@", responseObject);
        [self saveUserIdentifier:responseObject[@"identifier"]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        NSLog(@"%d", error.code);
    }];
}

#pragma mark - Singleton method

+ (instancetype)sharedInstance
{
    static id instance = nil;
    
    if (instance == nil)
        instance = [self new];
    
    return instance;
}

@end
