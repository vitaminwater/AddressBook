//
//  CCLocalSDK.m
//  Local
//
//  Created by stant on 13/04/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCLinotteAPI.h"

#import <AFNetworking/AFNetworking.h>

#import "CCGeohashHelper.h"

#import "CCAddress.h"
#import "CCList.h"



@implementation CCLinotteAPI
{
    AFHTTPSessionManager *_apiManager;
    AFHTTPSessionManager *_oauth2Manager;
    
    NSString *_clientId;
    NSString *_clientSecret;

    NSDateFormatter *_dateFormatter;
}

- (instancetype)initWithClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret
{
    self = [super init];
    if (self != nil) {
#if defined(DEBUG)
        NSURL *apiUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:8000", kCCLinotteAPIServer]];
#else
        NSURL *apiUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@", kCCLinotteAPIServer]];
#endif
        _clientId = clientId;
        _clientSecret = clientSecret;
        
        _apiManager = [[AFHTTPSessionManager alloc] initWithBaseURL:apiUrl];
        _apiManager.requestSerializer = [AFJSONRequestSerializer serializer];
        _apiManager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        _oauth2Manager = [[AFHTTPSessionManager alloc] initWithBaseURL:apiUrl];
        _oauth2Manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        _dateFormatter = [NSDateFormatter new];
        [_dateFormatter setLocale:[NSLocale currentLocale]];
        [_dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"];
        [_dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }
    return self;
}

#pragma mark - OAuth2 credentials

- (void)setOAuth2HTTPHeader:(NSString *)accessToken
{
    NSString *oauth2Header = [NSString stringWithFormat:@"Bearer %@", accessToken];
    [_apiManager.requestSerializer setValue:oauth2Header forHTTPHeaderField:@"Authorization"];
}

- (void)unsetOAuth2HttpHeader
{
    [_apiManager.requestSerializer setValue:nil forHTTPHeaderField:@"Authorization"];
}

#pragma mark - Authentication methods

- (NSURLSessionDataTask *)authenticate:(NSString *)username password:(NSString *)password success:(void(^)(NSString *accessToken, NSString *refreshToken, NSUInteger expiresIn))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSAssert(_clientId != nil && _clientSecret != nil, @"ClientId and/or clientSecret not set !");
    
    NSDictionary *parameters = [self oauth2Parameters:@{@"grant_type" : @"password", @"username" : username, @"password" : password}];
    return [_oauth2Manager POST:@"/oauth2/access_token/" parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        NSNumber *expiresIn = response[@"expires_in"];
        successBlock(response[@"access_token"], response[@"refresh_token"], [expiresIn unsignedIntegerValue]);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)refreshToken:(NSString *)refreshToken success:(void(^)(NSString *accessToken, NSString *refreshToken, NSUInteger expiresIn))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSAssert(_clientId != nil && _clientSecret != nil, @"ClientId and/or clientSecret not set !");

    NSDictionary *parameters = [self oauth2Parameters:@{@"grantType" : @"refresh_token", @"refresh_token" : refreshToken}];
    return [_oauth2Manager POST:@"/oauth2/refresh_token/" parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        NSNumber *expiresIn = response[@"expires_in"];
        successBlock(response[@"access_token"], response[@"refresh_token"], [expiresIn unsignedIntegerValue]);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
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


// TODO NSDictionary *parameters

/**
 * Parameters: username, first_name, last_name, email, password
 */
- (NSURLSessionDataTask *)createUser:(NSDictionary *)parameters success:(void(^)(NSString *identifier))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSAssert(_clientId != nil && _clientSecret != nil, @"ClientId and/or clientSecret not set !");
    
    return [_apiManager POST:@"/user/" parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        NSString *identifier = response[@"identifier"];
        successBlock(identifier);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

/**
 * Parameters: social_media_identifier, social_identifier, oauth_token, refresh_token, expiration_date
 */
- (NSURLSessionDataTask *)associateWithSocialAccount:(NSDictionary *)parameters success:(void(^)(NSString *identifier))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSAssert(_clientId != nil && _clientSecret != nil, @"ClientId and/or clientSecret not set !");
    
    return [_apiManager POST:@"/user/social/" parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        NSString *identifier = response[@"identifier"];
        successBlock(identifier);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSString *)UUID:(NSUInteger)len
{
    if (len)
        return [[[NSUUID UUID] UUIDString] substringToIndex:len];
    return [[NSUUID UUID] UUIDString];
}

#pragma mark - Device methods

- (NSURLSessionDataTask *)createDeviceWithSuccess:(void(^)(NSString *deviceId))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    return [_apiManager POST:@"/user/device/" parameters:nil success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        successBlock(response[@"identifier"]);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (void)setDeviceHTTPHeader:(NSString *)deviceId
{
    [_apiManager.requestSerializer setValue:deviceId forHTTPHeaderField:@"X-Linotte-Device-Id"];
}

- (void)unsetDeviceHTTPHeader
{
    [_apiManager.requestSerializer setValue:nil forHTTPHeaderField:@"X-Linotte-Device-Id"];
}

#pragma mark - Data management methods

- (NSURLSessionDataTask *)createAddress:(NSDictionary *)parameters success:(void(^)(NSString *identifier, NSInteger statusCode))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    return [_apiManager POST:@"/address/" parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        successBlock(response[@"identifier"], 200);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)createAddressMeta:(NSDictionary *)parameters success:(void(^)())successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSString *address_identifier = parameters[@"address"];
    
    if ([address_identifier length] == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = [NSError errorWithDomain:@"Missing identifier" code:CCMissingIdentifier userInfo:nil];
            failureBlock(nil, error);
        });
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"/address/%@/meta/", address_identifier];
    
    return [_apiManager POST:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        successBlock();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)createList:(NSDictionary *)parameters success:(void(^)(NSString *identifier))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    return [_apiManager POST:@"/list/" parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        successBlock(response[@"identifier"]);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)addList:(NSDictionary *)parameters success:(void(^)())successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSString *list_identifier = parameters[@"list"];
    if ([list_identifier length] == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = [NSError errorWithDomain:@"Missing identifier" code:CCMissingIdentifier userInfo:nil];
            failureBlock(nil, error);
        });
        return nil;
    }
    NSString *url = [NSString stringWithFormat:@"/user/list/%@/", list_identifier];
    return [_apiManager POST:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        successBlock();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)removeList:(NSDictionary *)parameters success:(void(^)())successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSString *list_identifier = parameters[@"list"];
    if ([list_identifier length] == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = [NSError errorWithDomain:@"Missing identifier" code:CCMissingIdentifier userInfo:nil];
            failureBlock(nil, error);
        });
        return nil;
    }
    NSString *url = [NSString stringWithFormat:@"/user/list/%@/", list_identifier];
    return [_apiManager DELETE:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        successBlock();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)removeAddress:(NSDictionary *)parameters success:(void(^)())successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSString *address_identifier = parameters[@"address"];
    if ([address_identifier length] == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = [NSError errorWithDomain:@"Missing identifier" code:CCMissingIdentifier userInfo:nil];
            failureBlock(nil, error);
        });
        return nil;
    }
    NSString *url = [NSString stringWithFormat:@"/user/address/%@/", address_identifier];
    return [_apiManager DELETE:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        successBlock();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)addAddressToList:(NSDictionary *)parameters success:(void(^)())successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSString *list_identifier = parameters[@"list"];
    NSString *address_identifier = parameters[@"address"];
    
    if ([list_identifier length] == 0 || [address_identifier length] == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = [NSError errorWithDomain:@"Missing identifier" code:CCMissingIdentifier userInfo:nil];
            failureBlock(nil, error);
        });
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"/list/%@/address/%@/", list_identifier, address_identifier];
    
    return [_apiManager POST:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        successBlock();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)removeAddressFromList:(NSDictionary *)parameters success:(void(^)())successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSString *list_identifier = parameters[@"list"];
    NSString *address_identifier = parameters[@"address"];
    
    if ([list_identifier length] == 0 || [address_identifier length] == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = [NSError errorWithDomain:@"Missing identifier" code:CCMissingIdentifier userInfo:nil];
            failureBlock(nil, error);
        });
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"/list/%@/address/%@/", list_identifier, address_identifier];
    
    return [_apiManager DELETE:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        successBlock();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)updateAddress:(NSDictionary *)parameters success:(void(^)())successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSString *address_identifier = [self popValueFromDict:@"address" dict:&parameters];
    
    if ([address_identifier length] == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = [NSError errorWithDomain:@"Missing identifier" code:CCMissingIdentifier userInfo:nil];
            failureBlock(nil, error);
        });
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"/address/%@/", address_identifier];
    return [_apiManager PUT:path parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        successBlock();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)updateList:(NSDictionary *)parameters success:(void(^)())successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSString *list_identifier = [self popValueFromDict:@"list" dict:&parameters];
    
    if ([list_identifier length] == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = [NSError errorWithDomain:@"Missing identifier" code:CCMissingIdentifier userInfo:nil];
            failureBlock(nil, error);
        });
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"/list/%@/", list_identifier];
    return [_apiManager PUT:path parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        successBlock();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)updateAddressUserData:(NSDictionary *)parameters success:(void(^)())successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSString *address_identifier = [self popValueFromDict:@"address" dict:&parameters];
    
    if ([address_identifier length] == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = [NSError errorWithDomain:@"Missing identifier" code:CCMissingIdentifier userInfo:nil];
            failureBlock(nil, error);
        });
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"/address/%@/data/", address_identifier];
    return [_apiManager POST:path parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        successBlock();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)updateListUserData:(NSDictionary *)parameters success:(void(^)())successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSString *list_identifier = [self popValueFromDict:@"list" dict:&parameters];
    
    if ([list_identifier length] == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = [NSError errorWithDomain:@"Missing identifier" code:CCMissingIdentifier userInfo:nil];
            failureBlock(nil, error);
        });
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"/list/%@/data/", list_identifier];
    return [_apiManager POST:path parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        successBlock();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
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

- (NSURLSessionTask *)fetchPublicLists:(CLLocationCoordinate2D)coordinates success:(void(^)(NSArray *lists))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSString *geohash = [CCGeohashHelper geohashFromCoordinates:coordinates];
    NSDictionary *parameters = @{@"geohash" : geohash};
    return [_apiManager GET:@"/list/public/" parameters:parameters success:^(NSURLSessionDataTask *task, NSArray *responses) {
        successBlock(responses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)fetchInstalledListsWithSuccess:(void(^)(NSArray *lists))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    return [_apiManager GET:@"/list/" parameters:nil success:^(NSURLSessionDataTask *task, NSArray *responses) {
        successBlock(responses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)fetchCompleteListInfos:(NSString *)identifier success:(void(^)(NSDictionary *listInfo))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSString *path = [NSString stringWithFormat:@"/list/%@/", identifier];
    return [_apiManager GET:path parameters:nil success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        successBlock(response);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)fetchListZones:(NSString *)identifier success:(void(^)(NSArray *listZones))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSString *path = [NSString stringWithFormat:@"/list/%@/zones/", identifier];
    return [_apiManager GET:path parameters:nil success:^(NSURLSessionDataTask *task, NSArray *responses) {
        successBlock(responses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)fetchAddressesFromList:(NSString *)identifier geohash:(NSString *)geohash lastAddressDate:(NSDate *)lastAddressDate limit:(NSUInteger)limit success:(void(^)(NSArray *addresses))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
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
        successBlock(responses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)fetchListEvents:(NSString *)identifier geohash:(NSString *)geohash lastDate:(NSDate *)lastDate success:(void(^)(NSArray *events))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSString *path = [NSString stringWithFormat:@"/list/%@/events/", identifier];
    NSString *lastDateString = [self stringFromDate:lastDate];
    NSDictionary *parameters = @{@"geohash" : geohash, @"last_date" : lastDateString};
    return [_apiManager GET:path parameters:parameters success:^(NSURLSessionDataTask *task, NSArray *responses) {
        successBlock(responses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)fetchListEvents:(NSString *)identifier lastDate:(NSDate *)lastDate success:(void(^)(NSArray *events))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSString *path = [NSString stringWithFormat:@"/list/%@/events/", identifier];
    NSString *lastDateString = [self stringFromDate:lastDate];
    NSDictionary *parameters = @{@"last_date" : lastDateString};
    return [_apiManager GET:path parameters:parameters success:^(NSURLSessionDataTask *task, NSArray *responses) {
        successBlock(responses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)fetchListZoneLastEventDate:(NSString *)identifier geohash:(NSString *)geohash success:(void(^)(NSDate *lastEventDate))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSString *path = [NSString stringWithFormat:@"/list/%@/events/", identifier];
    NSDictionary *parameters = @{@"geohash" : geohash, @"last_date_only" : @YES};
    return [_apiManager GET:path parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *lastEventDateDict) {
        NSDate *date = [self dateFromString:lastEventDateDict[@"last_date"]];
        successBlock(date);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)fetchListLastEventDate:(NSString *)identifier success:(void(^)(NSDate *lastEventDate))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSString *path = [NSString stringWithFormat:@"/list/%@/events/", identifier];
    NSDictionary *parameters = @{@"last_date_only" : @YES};
    return [_apiManager GET:path parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *lastEventDateDict) {
        NSDate *date = [self dateFromString:lastEventDateDict[@"last_date"]];
        successBlock(date);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)fetchUserLastEventDateWithSuccess:(void(^)(NSDate *lastEventDate))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSString *path = @"/events/";
    NSDictionary *parameters = @{@"last_date_only" : @YES};
    return [_apiManager GET:path parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *lastEventDateDict) {
        NSDate *date = [self dateFromString:lastEventDateDict[@"last_date"]];
        successBlock(date);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)fetchUserEventsWithLastDate:(NSDate *)lastDate success:(void(^)(NSArray *events))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSString *path = @"/user/events/";
    NSString *lastDateString = [self stringFromDate:lastDate];
    NSDictionary *parameters = @{@"last_date" : lastDateString};
    return [_apiManager GET:path parameters:parameters success:^(NSURLSessionDataTask *task, NSArray *responses) {
        successBlock(responses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)fetchAddressesForEventIds:(NSArray *)eventIds list:(NSString *)identifier success:(void(^)(NSArray *addresses))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSDictionary *parameters = @{@"e" : eventIds, @"list" : identifier};
    return [_apiManager GET:@"/event/address/" parameters:parameters success:^(NSURLSessionDataTask *task, NSArray *responses) {
        successBlock(responses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)fetchAddressMetasForEventIds:(NSArray *)eventIds success:(void(^)(NSArray *addressMetas))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSDictionary *parameters = @{@"e" : eventIds};
    return [_apiManager GET:@"/event/address_meta/" parameters:parameters success:^(NSURLSessionDataTask *task, NSArray *responses) {
        successBlock(responses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)fetchListMetasForEventIds:(NSArray *)eventIds success:(void(^)(NSArray *listMetas))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSDictionary *parameters = @{@"e" : eventIds};
    return [_apiManager GET:@"/event/list_meta/" parameters:parameters success:^(NSURLSessionDataTask *task, NSArray *responses) {
        successBlock(responses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)fetchAddressUserDataForEventIds:(NSArray *)eventIds success:(void(^)(NSArray *userDatas))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSDictionary *parameters = @{@"e" : eventIds};
    return [_apiManager GET:@"/event/address_user_data/" parameters:parameters success:^(NSURLSessionDataTask *task, NSArray *responses) {
        successBlock(responses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)fetchListUserDataForEventIds:(NSArray *)eventIds success:(void(^)(NSArray *userDatas))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSDictionary *parameters = @{@"e" : eventIds};
    return [_apiManager GET:@"/event/list_user_data/" parameters:parameters success:^(NSURLSessionDataTask *task, NSArray *responses) {
        successBlock(responses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)fetchListsForEventIds:(NSArray *)eventIds success:(void(^)(NSArray *lists))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSDictionary *parameters = @{@"e" : eventIds};
    return [_apiManager GET:@"/event/list/" parameters:parameters success:^(NSURLSessionDataTask *task, NSArray *responses) {
        successBlock(responses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
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

#pragma mark - error handling helper methods



@end
