//
//  CCLocalSDK.m
//  Local
//
//  Created by stant on 13/04/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCLinotteAPI.h"

#import <SSKeychain/SSKeychain.h>
#import <AFNetworking/AFNetworking.h>

#import "CCCoreDataStack.h"

#import "CCGeohashHelper.h"

#import "CCAddress.h"
#import "CCList.h"

// SSKeychain accounts
#if defined(DEBUG)
#define kCCKeyChainServiceName @"kCCKeyChainServiceNameDebug50"
#define kCCAccessTokenAccountName @"kCCAccessTokenAccountNameDebug"
#define kCCRefreshTokenAccountName @"kCCRefreshTokenAccountNameDebug"
#define kCCExpireTimeStampAccountName @"kCCExpireTimeStampAccountNameDebug"
#define kCCUserIdentifierAccountName @"kCCUserIdentifierAccountNameDebug"
#define kCCDeviceIdentifierAccountName @"kCCDeviceIdentifierAccountNameDebug"
#else
// #define kCCKeyChainServiceName @"kCCKeyChainServiceName6" // test
#define kCCKeyChainServiceName @"kCCKeyChainServiceName1000" // Apstore
#define kCCAccessTokenAccountName @"kCCAccessTokenAccountName"
#define kCCRefreshTokenAccountName @"kCCRefreshTokenAccountName"
#define kCCExpireTimeStampAccountName @"kCCExpireTimeStampAccountName"
#define kCCUserIdentifierAccountName @"kCCUserIdentifierAccountName"
#define kCCDeviceIdentifierAccountName @"kCCDeviceIdentifierAccountName"
#endif




/**
 * CCLinotteAPI interface
 */


@interface CCLinotteAPICredentials : NSObject
@property(nonatomic, strong)NSString *accessToken;
@property(nonatomic, strong)NSString *refreshToken;
@property(nonatomic, strong)NSString *expireTimeStamp;
@property(nonatomic, strong)NSString *deviceId;
@end

@implementation CCLinotteAPICredentials
@end



@implementation CCLinotteAPI
{
    
    AFHTTPSessionManager *_apiManager;
    AFHTTPSessionManager *_oauth2Manager;
    
    NSString *_clientId;
    NSString *_clientSecret;
    
    CCLinotteAPICredentials *_credentials;

    NSDateFormatter *_dateFormatter;
}

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
#if defined(DEBUG)
        NSURL *apiUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:8000", kCCLinotteAPIServer]];
#else
        NSURL *apiUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@", kCCLinotteAPIServer]];
#endif
        _apiManager = [[AFHTTPSessionManager alloc] initWithBaseURL:apiUrl];
        _apiManager.requestSerializer = [AFJSONRequestSerializer serializer];
        _apiManager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        _oauth2Manager = [[AFHTTPSessionManager alloc] initWithBaseURL:apiUrl];
        _oauth2Manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        [SSKeychain setAccessibilityType:kSecAttrAccessibleAlways];
        
        _credentials = [CCLinotteAPICredentials new];
        _credentials.accessToken = [SSKeychain passwordForService:kCCKeyChainServiceName account:kCCAccessTokenAccountName];
        _credentials.refreshToken = [SSKeychain passwordForService:kCCKeyChainServiceName account:kCCRefreshTokenAccountName];
        _identifier = [SSKeychain passwordForService:kCCKeyChainServiceName account:kCCUserIdentifierAccountName];
        _credentials.expireTimeStamp = [SSKeychain passwordForService:kCCKeyChainServiceName account:kCCExpireTimeStampAccountName];
        _credentials.deviceId = [SSKeychain passwordForService:kCCKeyChainServiceName account:kCCDeviceIdentifierAccountName];
        
        _dateFormatter = [NSDateFormatter new];
        [_dateFormatter setLocale:[NSLocale currentLocale]];
        [_dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"];
        [_dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

        [self refreshLoggedState];
        if (_loggedState != kCCFirstStart) {
            [self setOAuth2HTTPHeader];
            if (_loggedState == kCCLoggedIn) {
                [self setDeviceHTTPHeader];
            }
        }
    }
    return self;
}

- (void)refreshLoggedState
{
    if ([self isFirstStart])
        _loggedState = kCCFirstStart;
    else if (_credentials.expireTimeStamp == nil || [_credentials.expireTimeStamp integerValue] - 60 * 60 * 24 * 30 < [[NSDate date] timeIntervalSince1970])
        _loggedState = kCCRequestRefreshToken;
    else if (_credentials.deviceId == nil)
        _loggedState = kCCCreateDeviceId;
    else
        _loggedState = kCCLoggedIn;
}

- (BOOL)isFirstStart
{
    return ![[SSKeychain accountsForService:kCCKeyChainServiceName] count];
}

#pragma mark - API initialization method

- (void)APIIinitialization:(void(^)(CCLoggedState fromState))stateStepBlock completionBock:(void(^)(BOOL success))completionBlock
{
    if (_loggedState == kCCFirstStart) {
        [self createAndAuthenticateAnonymousUserWithCompletionBlock:^(BOOL success) {
            if (success) {
                [self refreshLoggedState];
                stateStepBlock(kCCFirstStart);
                [self APIIinitialization:stateStepBlock completionBock:completionBlock];
                return;
            }
            completionBlock(NO);
        }];
    } else if (_loggedState == kCCRequestRefreshToken) {
        [self refreshTokenWithCompletionBlock:^(BOOL success) {
            if (success) {
                [self refreshLoggedState];
                stateStepBlock(kCCRequestRefreshToken);
                [self APIIinitialization:stateStepBlock completionBock:completionBlock];
                return;
            }
            completionBlock(NO);
        }];
    } else if (_loggedState == kCCCreateDeviceId) {
        [self createDevice:^(BOOL success) {
            if (success) {
                [self refreshLoggedState];
                stateStepBlock(kCCCreateDeviceId);
                [self APIIinitialization:stateStepBlock completionBock:completionBlock];
                return;
            }
            completionBlock(NO);
        }];
    } else if (_loggedState == kCCLoggedIn) {
        completionBlock(YES);
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
    NSString *oauth2Header = [NSString stringWithFormat:@"Bearer %@", _credentials.accessToken];
    [_apiManager.requestSerializer setValue:oauth2Header forHTTPHeaderField:@"Authorization"];
}

#pragma mark - Authentication methods

- (void)authenticate:(NSString *)username password:(NSString *)password completionBlock:(void(^)(BOOL success))completionBlock
{
    NSAssert(_clientId != nil && _clientSecret != nil, @"ClientId and/or clientSecret not set !");
    
    NSDictionary *parameters = [self oauth2Parameters:@{@"grant_type" : @"password", @"username" : username, @"password" : password}];
    [_oauth2Manager POST:@"/oauth2/access_token/" parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        NSNumber *expiresIn = response[@"expires_in"];
        NSString *expiresInString = [NSString stringWithFormat:@"%d", (int)([[NSDate date] timeIntervalSince1970] + [expiresIn integerValue])];
        [self saveTokens:response[@"access_token"] refreshToken:response[@"refresh_token"] expireTimeStamp:expiresInString];
        completionBlock(YES);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        completionBlock(NO);
    }];
}

- (void)refreshTokenWithCompletionBlock:(void(^)(BOOL success))completionBlock
{
    NSAssert(_clientId != nil && _clientSecret != nil, @"ClientId and/or clientSecret not set !");
    NSAssert(_credentials.refreshToken != nil, @"Refresh token not set !");

    NSDictionary *parameters = [self oauth2Parameters:@{@"grantType" : @"refresh_token", @"refresh_token" : _credentials.refreshToken}];
    [_oauth2Manager POST:@"/oauth2/refresh_token/" parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        [self saveTokens:response[@"access_token"] refreshToken:response[@"refresh_token"] expireTimeStamp:response[@"expires_in"]];
        completionBlock(YES);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        completionBlock(NO);
    }];
}

- (void)saveTokens:(NSString *)accessToken refreshToken:(NSString *)refreshToken expireTimeStamp:(NSString *)expireTimeStamp
{
    NSError *error;
    
    _credentials.accessToken = accessToken;
    _credentials.refreshToken = refreshToken;
    _credentials.expireTimeStamp = expireTimeStamp;
    if ([SSKeychain setPassword:accessToken forService:kCCKeyChainServiceName account:kCCAccessTokenAccountName error:&error] == NO) {
        CCLog(@"%@", error);
    }
    
    if ([SSKeychain setPassword:refreshToken forService:kCCKeyChainServiceName account:kCCRefreshTokenAccountName error:&error] == NO) {
        CCLog(@"%@", error);
    }
    
    if ([SSKeychain setPassword:expireTimeStamp forService:kCCKeyChainServiceName account:kCCExpireTimeStampAccountName error:&error] == NO) {
        CCLog(@"%@", error);
    }
    [self setOAuth2HTTPHeader];
}

- (NSDictionary *)oauth2Parameters:(NSDictionary *)parameters
{
    NSMutableDictionary *mutableDictionnary = [parameters mutableCopy];
    mutableDictionnary[@"client_id"] = _clientId;
    mutableDictionnary[@"client_secret"] = _clientSecret;
    mutableDictionnary[@"scope"] = @"read+write";
    return [mutableDictionnary copy];
}

#pragma mark - User methods

- (void)createAndAuthenticateAnonymousUserWithCompletionBlock:(void(^)(BOOL success))completionBlock
{
    NSAssert(_clientId != nil && _clientSecret != nil, @"ClientId and/or clientSecret not set !");
    
    NSString *(^UUID)(NSUInteger len) = ^NSString *(NSUInteger len){
        if (len)
            return [[[NSUUID UUID] UUIDString] substringToIndex:30];
        return [[NSUUID UUID] UUIDString];
        
    };
    NSString *email = [NSString stringWithFormat:@"%@@getcairnsapp.com", UUID(0)];
    NSString *username = UUID(30);
    NSString *password = UUID(0);
    NSDictionary *parameters = @{@"username" : username, @"password" : password, @"first_name" : UUID(30), @"last_name" : UUID(30), @"email" : email};
    [_apiManager POST:@"/user/" parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        [self authenticate:username password:password completionBlock:^(BOOL success) {
            NSString *identifier = response[@"identifier"];
            if (success)
                [self saveUserIdentifier:identifier];
            completionBlock(success);
        }];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        completionBlock(NO);
    }];
}

- (void)saveUserIdentifier:(NSString *)identifier {
    NSError *error;
    if ([SSKeychain setPassword:identifier forService:kCCKeyChainServiceName account:kCCUserIdentifierAccountName error:&error] == NO) {
        CCLog(@"%@", error);
    }
    _identifier = identifier;
}

#pragma mark - Device methods

- (void)createDevice:(void(^)(BOOL success))completionBlock
{
    [_apiManager POST:@"/user/device/" parameters:nil success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        [self saveDeviceId:response[@"identifier"]];
        [self setDeviceHTTPHeader];
        completionBlock(YES);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        completionBlock(NO);
    }];
}

- (void)saveDeviceId:(NSString *)deviceId
{
    NSError *error = nil;
    _credentials.deviceId = deviceId;
    if ([SSKeychain setPassword:deviceId forService:kCCKeyChainServiceName account:kCCDeviceIdentifierAccountName error:&error] == NO) {
        CCLog(@"%@", error);
    }
}

- (void)setDeviceHTTPHeader
{
    [_apiManager.requestSerializer setValue:_credentials.deviceId forHTTPHeaderField:@"X-Linotte-Device-Id"];
}

#pragma mark - Data management methods

- (void)createAddress:(NSDictionary *)parameters completionBlock:(void(^)(BOOL success, NSString *identifier, NSInteger statusCode))completionBlock
{
    [_apiManager POST:@"/address/" parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        completionBlock(YES, response[@"identifier"], 200);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        completionBlock(NO, nil, response.statusCode);
    }];
}

- (void)createList:(NSDictionary *)parameters completionBlock:(void(^)(BOOL success, NSString *identifier, NSInteger statusCode))completionBlock
{
    [_apiManager POST:@"/list/" parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        completionBlock(YES, response[@"identifier"], 200);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        completionBlock(NO, nil, response.statusCode);
    }];
}

- (void)addList:(NSDictionary *)parameters completionBlock:(void(^)(BOOL success, NSInteger statusCode))completionBlock
{
    NSString *url = [NSString stringWithFormat:@"/user/list/%@/", parameters[@"list"]];
    [_apiManager POST:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        completionBlock(YES, 200);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        completionBlock(NO, response.statusCode);
    }];
}

- (void)removeList:(NSDictionary *)parameters completionBlock:(void(^)(BOOL success, NSInteger statusCode))completionBlock
{
    NSString *url = [NSString stringWithFormat:@"/user/list/%@/", parameters[@"list"]];
    [_apiManager DELETE:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        completionBlock(YES, 200);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        completionBlock(NO, response.statusCode);
    }];
}

- (void)removeAddress:(NSDictionary *)parameters completionBlock:(void(^)(BOOL success, NSInteger statusCode))completionBlock
{
    NSString *url = [NSString stringWithFormat:@"/user/address/%@/", parameters[@"address"]];
    [_apiManager DELETE:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        completionBlock(YES, 200);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        completionBlock(NO, response.statusCode);
    }];
}

- (void)addAddressToList:(NSDictionary *)parameters completionBlock:(void(^)(BOOL success, NSInteger statusCode))completionBlock
{
    NSString *path = [NSString stringWithFormat:@"/list/%@/address/%@/", parameters[@"list"], parameters[@"address"]];
    
    [_apiManager POST:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        completionBlock(YES, 200);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        completionBlock(NO, response.statusCode);
    }];
}

- (void)removeAddressFromList:(NSDictionary *)parameters completionBlock:(void(^)(BOOL success, NSInteger statusCode))completionBlock
{
    NSString *path = [NSString stringWithFormat:@"/list/%@/address/%@/", parameters[@"list"], parameters[@"address"]];
    
    [_apiManager DELETE:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        completionBlock(YES, 200);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        completionBlock(NO, response.statusCode);
    }];
}

- (void)updateAddress:(NSDictionary *)parameters completionBlock:(void(^)(BOOL success, NSInteger statusCode))completionBlock
{
    NSString *address = [self popValueFromDict:@"address" dict:&parameters];
    NSString *path = [NSString stringWithFormat:@"/address/%@/", address];
    [_apiManager PUT:path parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        completionBlock(YES, 200);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        completionBlock(NO, response.statusCode);
    }];
}

- (void)updateList:(NSDictionary *)parameters completionBlock:(void(^)(BOOL success, NSInteger statusCode))completionBlock
{
    NSString *list = [self popValueFromDict:@"list" dict:&parameters];
    NSString *path = [NSString stringWithFormat:@"/list/%@/", list];
    [_apiManager PUT:path parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        completionBlock(YES, 200);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        completionBlock(NO, response.statusCode);
    }];
}

- (void)updateAddressUserData:(NSDictionary *)parameters completionBlock:(void(^)(BOOL success, NSInteger statusCode))completionBlock
{
    NSString *address = [self popValueFromDict:@"address" dict:&parameters];
    NSString *path = [NSString stringWithFormat:@"/address/%@/data/", address];
    [_apiManager POST:path parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        completionBlock(YES, 200);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        completionBlock(NO, response.statusCode);
    }];
}

- (void)updateListUserData:(NSDictionary *)parameters completionBlock:(void(^)(BOOL success, NSInteger statusCode))completionBlock
{
    NSString *list = [self popValueFromDict:@"list" dict:&parameters];
    NSString *path = [NSString stringWithFormat:@"/list/%@/data/", list];
    [_apiManager POST:path parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        completionBlock(YES, 200);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        completionBlock(NO, response.statusCode);
    }];
}

- (id)popValueFromDict:(id)key dict:(NSDictionary **)dict
{
    NSMutableDictionary *mutableDict = [*dict mutableCopy];
    id value = mutableDict[key];
    [mutableDict removeObjectForKey:key];
    *dict = mutableDict;
    return value;
}

#pragma mark - Fetch methods

- (NSURLSessionTask *)fetchPublicLists:(CLLocationCoordinate2D)coordinates completionBlock:(void(^)(BOOL success, NSArray *lists))completionBlock
{
    NSString *geohash = [CCGeohashHelper geohashFromCoordinates:coordinates];
    NSDictionary *parameters = @{@"geohash" : geohash};
    return [_apiManager GET:@"/list/public/" parameters:parameters success:^(NSURLSessionDataTask *task, NSArray *responses) {
        completionBlock(YES, responses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        completionBlock(NO, nil);
    }];
}

- (NSURLSessionTask *)fetchInstalledListsWithCompletionBlock:(void(^)(BOOL success, NSArray *lists))completionBlock
{
    return [_apiManager GET:@"/list/" parameters:nil success:^(NSURLSessionDataTask *task, NSArray *responses) {
        completionBlock(YES, responses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        completionBlock(NO, nil);
    }];
}

- (NSURLSessionTask *)fetchCompleteListInfos:(NSString *)identifier completionBlock:(void(^)(BOOL success, NSDictionary *listInfo))completionBlock
{
    NSString *path = [NSString stringWithFormat:@"/list/%@/", identifier];
    return [_apiManager GET:path parameters:nil success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        completionBlock(YES, response);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        completionBlock(NO, nil);
    }];
}

- (NSURLSessionTask *)fetchListZones:(NSString *)identifier completionBlock:(void(^)(BOOL success, NSArray *listZones))completionBlock
{
    NSString *path = [NSString stringWithFormat:@"/list/%@/zones/", identifier];
    return [_apiManager GET:path parameters:nil success:^(NSURLSessionDataTask *task, NSArray *responses) {
        completionBlock(YES, responses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        completionBlock(NO, nil);
    }];
}

- (NSURLSessionTask *)fetchAddressesFromList:(NSString *)identifier geohash:(NSString *)geohash lastAddressDate:(NSDate *)lastAddressDate limit:(NSUInteger)limit completionBlock:(void(^)(BOOL success, NSArray *addresses))completionBlock
{
    NSString *path = [NSString stringWithFormat:@"/list/%@/addresses/", identifier];
    NSDictionary *parameters;
    if (lastAddressDate != nil) {
        NSString *lastAddressDateString = [self stringFromDate:lastAddressDate];
        parameters = @{@"last_address_date" : lastAddressDateString, @"limit" : @(limit), @"geohash" : geohash};
    } else {
        parameters = @{@"limit" : @(limit), @"geohash" : geohash};
    }
    return [_apiManager GET:path parameters:parameters success:^(NSURLSessionDataTask *task, NSArray *responses) {
        completionBlock(YES, responses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        completionBlock(NO, nil);
    }];
}

- (NSURLSessionTask *)fetchListEvents:(NSString *)identifier geohash:(NSString *)geohash lastDate:(NSDate *)lastDate completionBlock:(void(^)(BOOL success, NSArray *events))completionBlock
{
    NSString *path = [NSString stringWithFormat:@"/list/%@/events/", identifier];
    NSString *lastDateString = [self stringFromDate:lastDate];
    NSDictionary *parameters = @{@"geohash" : geohash, @"last_date" : lastDateString};
    return [_apiManager GET:path parameters:parameters success:^(NSURLSessionDataTask *task, NSArray *responses) {
        completionBlock(YES, responses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        completionBlock(NO, nil);
    }];
}

- (NSURLSessionTask *)fetchListEvents:(NSString *)identifier lastDate:(NSDate *)lastDate completionBlock:(void(^)(BOOL success, NSArray *events))completionBlock
{
    NSString *path = [NSString stringWithFormat:@"/list/%@/events/", identifier];
    NSString *lastDateString = [self stringFromDate:lastDate];
    NSDictionary *parameters = @{@"last_date" : lastDateString};
    return [_apiManager GET:path parameters:parameters success:^(NSURLSessionDataTask *task, NSArray *responses) {
        completionBlock(YES, responses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        completionBlock(NO, nil);
    }];
}

- (NSURLSessionTask *)fetchListZoneLastEventDate:(NSString *)identifier geohash:(NSString *)geohash completionBlock:(void(^)(BOOL success, NSDate *lastEventDate))completionBlock
{
    NSString *path = [NSString stringWithFormat:@"/list/%@/events/", identifier];
    NSDictionary *parameters = @{@"geohash" : geohash, @"last_date_only" : @YES};
    return [_apiManager GET:path parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *lastEventDateDict) {
        NSDate *date = [self dateFromString:lastEventDateDict[@"last_date"]];
        completionBlock(YES, date);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        completionBlock(NO, nil);
    }];
}

- (NSURLSessionTask *)fetchListLastEventDate:(NSString *)identifier completionBlock:(void(^)(BOOL success, NSDate *lastEventDate))completionBlock
{
    NSString *path = [NSString stringWithFormat:@"/list/%@/events/", identifier];
    NSDictionary *parameters = @{@"last_date_only" : @YES};
    return [_apiManager GET:path parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *lastEventDateDict) {
        NSDate *date = [self dateFromString:lastEventDateDict[@"last_date"]];
        completionBlock(YES, date);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        completionBlock(NO, nil);
    }];
}

- (NSURLSessionTask *)fetchUserLastEventDateWithCompletionBlock:(void(^)(BOOL success, NSDate *lastEventDate))completionBlock
{
    NSString *path = @"/events/";
    NSDictionary *parameters = @{@"last_date_only" : @YES};
    return [_apiManager GET:path parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *lastEventDateDict) {
        NSDate *date = [self dateFromString:lastEventDateDict[@"last_date"]];
        completionBlock(YES, date);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        completionBlock(NO, nil);
    }];
}

- (NSURLSessionTask *)fetchUserEventsWithLastDate:(NSDate *)lastDate completionBlock:(void(^)(BOOL success, NSArray *events))completionBlock
{
    NSString *path = @"/user/events/";
    NSString *lastDateString = [self stringFromDate:lastDate];
    NSDictionary *parameters = @{@"last_date" : lastDateString};
    return [_apiManager GET:path parameters:parameters success:^(NSURLSessionDataTask *task, NSArray *responses) {
        completionBlock(YES, responses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        completionBlock(NO, nil);
    }];
}

- (NSURLSessionTask *)fetchAddressesForEventIds:(NSArray *)eventIds completionBlock:(void(^)(BOOL success, NSArray *addresses))completionBlock
{
    NSDictionary *parameters = @{@"e" : eventIds};
    return [_apiManager GET:@"/event/address/" parameters:parameters success:^(NSURLSessionDataTask *task, NSArray *responses) {
        completionBlock(YES, responses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        completionBlock(NO, nil);
    }];
}

- (NSURLSessionTask *)fetchAddressMetasForEventIds:(NSArray *)eventIds completionBlock:(void(^)(BOOL success, NSArray *addressMetas))completionBlock
{
    NSDictionary *parameters = @{@"e" : eventIds};
    return [_apiManager GET:@"/event/address_meta/" parameters:parameters success:^(NSURLSessionDataTask *task, NSArray *responses) {
        completionBlock(YES, responses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        completionBlock(NO, nil);
    }];
}

- (NSURLSessionTask *)fetchListMetasForEventIds:(NSArray *)eventIds completionBlock:(void(^)(BOOL success, NSArray *listMetas))completionBlock
{
    NSDictionary *parameters = @{@"e" : eventIds};
    return [_apiManager GET:@"/event/list_meta/" parameters:parameters success:^(NSURLSessionDataTask *task, NSArray *responses) {
        completionBlock(YES, responses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        completionBlock(NO, nil);
    }];
}

- (NSURLSessionTask *)fetchAddressUserDataForEventIds:(NSArray *)eventIds completionBlock:(void(^)(BOOL success, NSArray *userDatas))completionBlock
{
    NSDictionary *parameters = @{@"e" : eventIds};
    return [_apiManager GET:@"/event/address_user_data/" parameters:parameters success:^(NSURLSessionDataTask *task, NSArray *responses) {
        completionBlock(YES, responses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        completionBlock(NO, nil);
    }];
}

- (NSURLSessionTask *)fetchListUserDataForEventIds:(NSArray *)eventIds completionBlock:(void(^)(BOOL success, NSArray *userDatas))completionBlock
{
    NSDictionary *parameters = @{@"e" : eventIds};
    return [_apiManager GET:@"/event/list_user_data/" parameters:parameters success:^(NSURLSessionDataTask *task, NSArray *responses) {
        completionBlock(YES, responses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        completionBlock(NO, nil);
    }];
}

- (NSURLSessionTask *)fetchListsForEventIds:(NSArray *)eventIds completionBlock:(void(^)(BOOL success, NSArray *lists))completionBlock
{
    NSDictionary *parameters = @{@"e" : eventIds};
    return [_apiManager GET:@"/event/list/" parameters:parameters success:^(NSURLSessionDataTask *task, NSArray *responses) {
        completionBlock(YES, responses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        completionBlock(NO, nil);
    }];
}

#pragma mark - Date conversion methods

- (NSString *)stringFromDate:(NSDate *)date
{
    return [_dateFormatter stringFromDate:date];
}

- (NSDate *)dateFromString:(NSString *)dateString
{
    return [_dateFormatter dateFromString:dateString];
}

#pragma mark - Singleton method

+ (instancetype)sharedInstance
{
    static id instance = nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        instance = [self new];
    });
    
    return instance;
}

@end
