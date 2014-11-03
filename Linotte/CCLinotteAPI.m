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
 * Model returned for public list
 */

@implementation CCPublicListModel
@end


/**
 * Model returned for list complete infos
 */

@implementation CCCompleteListInfoModel
@end

/**
 * Model returned for list geohash zones
 */

@implementation CCListGeohashZoneModel
@end

/**
 * Model returned for address fetch
 */

@implementation CCAddressModel
@end

/**
 * Model returned for event fetch
 */

@implementation CCServerEventModel
@end

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
        [_dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SS'Z'"];
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
        NSLog(@"%@", error);
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
        NSLog(@"%@", error);
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
        NSLog(@"%@", error);
    }
    
    if ([SSKeychain setPassword:refreshToken forService:kCCKeyChainServiceName account:kCCRefreshTokenAccountName error:&error] == NO) {
        NSLog(@"%@", error);
    }
    
    if ([SSKeychain setPassword:expireTimeStamp forService:kCCKeyChainServiceName account:kCCExpireTimeStampAccountName error:&error] == NO) {
        NSLog(@"%@", error);
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
        NSLog(@"%@", error);
        completionBlock(NO);
    }];
}

- (void)saveUserIdentifier:(NSString *)identifier {
    NSError *error;
    if ([SSKeychain setPassword:identifier forService:kCCKeyChainServiceName account:kCCUserIdentifierAccountName error:&error] == NO) {
        NSLog(@"%@", error);
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
        NSLog(@"%@", error);
        completionBlock(NO);
    }];
}

- (void)saveDeviceId:(NSString *)deviceId
{
    NSError *error = nil;
    _credentials.deviceId = deviceId;
    if ([SSKeychain setPassword:deviceId forService:kCCKeyChainServiceName account:kCCDeviceIdentifierAccountName error:&error] == NO) {
        NSLog(@"%@", error);
    }
}

- (void)setDeviceHTTPHeader
{
    [_apiManager.requestSerializer setValue:_credentials.deviceId forHTTPHeaderField:@"X-Linotte-Device-Id"];
}

#pragma mark - Data management methods

- (void)createAddress:(CCAddress *)address completionBlock:(void(^)(BOOL success))completionBlock
{
    CCList *list = [[address.lists allObjects] firstObject];
    NSDictionary *parameters = @{@"name" : address.name, @"address" : address.address, @"latitude" : address.latitude, @"longitude" : address.longitude, @"provider" : address.provider, @"provider_id" : address.providerId, @"list" : list.identifier};
    [_apiManager POST:@"/address/" parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        address.identifier = response[@"identifier"];
        completionBlock(YES);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", error);
        completionBlock(NO);
    }];
}

- (void)createList:(CCList *)list completionBlock:(void(^)(BOOL success))completionBlock
{
    NSDictionary *parameters = @{@"name" : list.name};
    [_apiManager POST:@"/list/" parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        list.identifier = response[@"identifier"];
        completionBlock(YES);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", error);
        completionBlock(NO);
    }];
}

- (void)addList:(CCList *)list completionBlock:(void(^)(BOOL success))completionBlock
{
    NSString *url = [NSString stringWithFormat:@"/user/list/%@/", list.identifier];
    [_apiManager POST:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        completionBlock(YES);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", error);
        completionBlock(NO);
    }];
}

- (void)removeList:(NSString *)identifier completionBlock:(void(^)(BOOL success))completionBlock
{
    NSString *url = [NSString stringWithFormat:@"/user/list/%@/", identifier];
    [_apiManager DELETE:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        completionBlock(YES);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", error);
        completionBlock(NO);
    }];
}

- (void)removeAddress:(NSString *)identifier completionBlock:(void(^)(BOOL success))completionBlock
{
    NSString *url = [NSString stringWithFormat:@"/user/address/%@/", identifier];
    [_apiManager DELETE:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        completionBlock(YES);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", error);
        completionBlock(NO);
    }];
}

- (void)addAddress:(CCAddress *)address toList:(CCList *)list completionBlock:(void(^)(BOOL success))completionBlock
{
    NSString *path = [NSString stringWithFormat:@"/list/%@/address/%@/", list.identifier, address.identifier];
    
    [_apiManager POST:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        completionBlock(YES);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", error);
        completionBlock(NO);
    }];
}

- (void)removeAddress:(CCAddress *)address fromList:(CCList *)list completionBlock:(void(^)(BOOL success))completionBlock
{
    NSString *path = [NSString stringWithFormat:@"/list/%@/address/%@/", list.identifier, address.identifier];
    
    [_apiManager DELETE:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        completionBlock(YES);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", error);
        completionBlock(NO);
    }];
}

- (void)updateAddress:(CCAddress *)address completionBlock:(void(^)(BOOL success))completionBlock
{
    NSDictionary *parameters = @{@"name" : address.name, @"address" : address.address, @"latitude" : address.latitude, @"longitude" : address.longitude};
    NSString *path = [NSString stringWithFormat:@"/address/%@/", address.identifier];
    [_apiManager PUT:path parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        completionBlock(YES);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", error);
        completionBlock(NO);
    }];
}

- (void)updateList:(CCList *)list completionBlock:(void(^)(BOOL success))completionBlock
{
    NSDictionary *parameters = @{@"name" : list.name};
    NSString *path = [NSString stringWithFormat:@"/list/%@/", list.identifier];
    [_apiManager PUT:path parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        completionBlock(YES);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", error);
        completionBlock(NO);
    }];
}

- (void)updateAddressUserData:(CCAddress *)address completionBlock:(void(^)(BOOL success))completionBlock
{
    NSString *note = address.note ? address.note : @"";
    NSDictionary *parameters = @{@"note" : note, @"notification" : @(address.notifyValue)};
    NSString *path = [NSString stringWithFormat:@"/address/%@/data/", address.identifier];
    [_apiManager POST:path parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        completionBlock(YES);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", error);
        completionBlock(NO);
    }];
}

#pragma mark - Fetch methods

- (void)fetchPublicLists:(CLLocationCoordinate2D)coordinates completionBlock:(void(^)(BOOL success, NSArray *lists))completionBlock
{
    NSString *geohash = [CCGeohashHelper geohashFromCoordinates:coordinates];
    NSDictionary *parameters = @{@"geohash" : geohash};
    [_apiManager GET:@"/list/public/" parameters:parameters success:^(NSURLSessionDataTask *task, NSArray *responses) {
        NSMutableArray *result = [@[] mutableCopy];
        for (NSDictionary *list in responses) {
            CCPublicListModel *publicListModel = [CCPublicListModel new];
            publicListModel.identifier = list[@"identifier"];
            publicListModel.name = list[@"name"];
            publicListModel.icon = list[@"icon"];
            [result addObject:publicListModel];
        }
        completionBlock(YES, result);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", error);
        completionBlock(NO, nil);
    }];
}

- (void)fetchCompleteListInfos:(NSString *)identifier completionBlock:(void(^)(BOOL success, CCCompleteListInfoModel *completeListInfoModel))completionBlock
{
    NSString *path = [NSString stringWithFormat:@"/list/%@/", identifier];
    [_apiManager GET:path parameters:nil success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        CCCompleteListInfoModel *listComplete = [CCCompleteListInfoModel new];
        listComplete.identifier = identifier;
        listComplete.name = response[@"name"];
        listComplete.icon = response[@"icon"];
        listComplete.numberOfAddresses = response[@"n_addresses"];
        listComplete.numberOfInstalls = response[@"n_installs"];
        listComplete.lastUpdate = [_dateFormatter dateFromString:response[@"last_update"]];
        listComplete.author = response[@"author"];
        listComplete.authorId = response[@"author_id"];
        completionBlock(YES, listComplete);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", error);
        completionBlock(NO, nil);
    }];
}

- (void)fetchListZones:(NSString *)identifier completionBlock:(void(^)(BOOL success, NSArray *listZones))completionBlock
{
    NSString *path = [NSString stringWithFormat:@"/list/%@/zones/", identifier];
    [_apiManager GET:path parameters:nil success:^(NSURLSessionDataTask *task, NSArray *responses) {
        NSMutableArray *results = [@[] mutableCopy];
        for (NSDictionary *response in responses) {
            CCListGeohashZoneModel *listGeohashZone = [CCListGeohashZoneModel new];
            listGeohashZone.geohash = response[@"geohash"];
            listGeohashZone.nAddresses = response[@"n_addresses"];
            [results addObject:listGeohashZone];
        }
        completionBlock(YES, results);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", error);
        completionBlock(NO, nil);
    }];
}

- (void)fetchAddressesFromList:(NSString *)identifier geohash:(NSString *)geohash lastAddressDate:(NSDate *)lastAddressDate limit:(NSUInteger)limit completionBlock:(void(^)(BOOL success, NSArray *addresses))completionBlock
{
    NSString *path = [NSString stringWithFormat:@"/list/%@/addresses/", identifier];
    NSDictionary *parameters;
    if (lastAddressDate != nil) {
        NSString *dateString = [_dateFormatter stringFromDate:lastAddressDate];
        parameters = @{@"lastAddressDate" : dateString, @"limit" : @(limit), @"geohash" : geohash};
    } else {
        parameters = @{@"limit" : @(limit), @"geohash" : geohash};
    }
    [_apiManager GET:path parameters:parameters success:^(NSURLSessionDataTask *task, NSArray *responses) {
        NSMutableArray *addresses = [@[] mutableCopy];
        for (NSDictionary *response in responses) {
            CCAddressModel *address = [CCAddressModel new];
            address.identifier = response[@"identifier"];
            address.latitude = response[@"latitude"];
            address.longitude = response[@"longitude"];
            address.name = response[@"name"];
            address.address = response[@"address"];
            address.provider = response[@"provider"];
            address.providerId = response[@"provider_id"];
            NSDate *dateCreated = [_dateFormatter dateFromString:response[@"date_created"]];
            address.dateCreated = dateCreated;
            address.note = response[@"note"];
            address.notification = response[@"notification"];
            [addresses addObject:address];
        }
        completionBlock(YES, addresses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", error);
        completionBlock(NO, nil);
    }];
}

- (void)fetchListEvents:(NSString *)identifier geohash:(NSString *)geohash lastId:(NSNumber *)lastId completionBlock:(void(^)(BOOL success, NSArray *events))completionBlock
{
    NSString *path = [NSString stringWithFormat:@"/event/%@/consume/", identifier];
    NSDictionary *parameters = @{@"geohash" : geohash, @"last_id" : lastId};
    [_apiManager GET:path parameters:parameters success:^(NSURLSessionDataTask *task, NSArray *responses) {
        NSMutableArray *serverEvents = [@[] mutableCopy];
        for (NSDictionary *response in responses) {
            CCServerEventModel *serverEventModel = [CCServerEventModel new];
            serverEventModel.id = response[@"id"];
            serverEventModel.event = response[@"event"];
            serverEventModel.objectIdentifier = response[@"object_identifier"];
            [serverEvents addObject:serverEventModel];
        }
        completionBlock(YES, serverEvents);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", error);
        completionBlock(NO, nil);
    }];
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
