//
//  CCLocalSDK.m
//  Local
//
//  Created by stant on 13/04/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCLinotteAPI.h"

#import <AFNetworking/AFNetworking.h>

#import "CCJSONResponseSerializer.h"

#import "CCGeohashHelper.h"

#import "CCAddress.h"
#import "CCList.h"


#define kCCLinotteAPIVersionPrefix @"v2"
#define LURL(url) [NSString stringWithFormat:@"/%@%@", kCCLinotteAPIVersionPrefix, url]


@implementation CCLinotteAPI
{
    AFHTTPSessionManager *_apiManager;
    
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
        _apiManager.responseSerializer = [CCJSONResponseSerializer serializer];
        
        _dateFormatter = [NSDateFormatter new];
        [_dateFormatter setLocale:[NSLocale currentLocale]];
        [_dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"];
        [_dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }
    return self;
}

#pragma mark - OAuth2 credentials

- (void)setAuthHTTPHeader:(NSString *)accessToken
{
    NSString *authHeader = [NSString stringWithFormat:@"Linotte %@", accessToken];
    [_apiManager.requestSerializer setValue:authHeader forHTTPHeaderField:@"Authorization"];
}

- (void)unsetAuthHttpHeader
{
    [_apiManager.requestSerializer setValue:nil forHTTPHeaderField:@"Authorization"];
}

#pragma mark - Authentication methods

/**
 * Parameters: type, infos (see auth methods doc, coming soon)
 */
- (NSURLSessionDataTask *)authenticate:(NSDictionary *)parameters success:(void(^)(NSString *identifier, NSString *accessToken, NSString *authMethodIdentifier))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSAssert(_clientId != nil && _clientSecret != nil, @"ClientId and/or clientSecret not set !");
    
    return [_apiManager POST:LURL(@"/user/login/") parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        successBlock(response[@"identifier"], response[@"access_token"], response[@"auth_method"]);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

#pragma mark - User methods

// TODO NSDictionary *parameters

/**
 * Parameters: type, infos (see auth methods doc, coming soon), display_name
 */
- (NSURLSessionDataTask *)createUser:(NSDictionary *)parameters success:(void(^)(NSString *identifier, NSString *accessToken, NSString *authMethodIdentifier))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSAssert(_clientId != nil && _clientSecret != nil, @"ClientId and/or clientSecret not set !");
    
    return [_apiManager POST:LURL(@"/user/") parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        NSString *identifier = response[@"identifier"];
        NSString *accessToken = response[@"access_token"];
        NSString *authMethodIdentifier = response[@"auth_method_identifier"];
        successBlock(identifier, accessToken, authMethodIdentifier);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

/**
 * Parameters: type, infos (see auth methods doc, coming soon)
 */
- (NSURLSessionDataTask *)addAuthenticationMethod:(NSDictionary *)parameters success:(void(^)(NSString *identifier))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSAssert(_clientId != nil && _clientSecret != nil, @"ClientId and/or clientSecret not set !");
    
    return [_apiManager POST:LURL(@"/user/auth/") parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *response) {
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
    return [_apiManager POST:LURL(@"/user/device/") parameters:@{} success:^(NSURLSessionDataTask *task, NSDictionary *response) {
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
    return [_apiManager POST:LURL(@"/address/") parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *response) {
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
    
    return [_apiManager POST:LURL(@"/addressmeta/") parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        successBlock();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)createList:(NSDictionary *)parameters success:(void(^)(NSString *identifier))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    return [_apiManager POST:LURL(@"/list/") parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        successBlock(response[@"identifier"]);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)addList:(NSDictionary *)parameters success:(void(^)())successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSString *list_identifier = [self popValueFromDict:@"list" dict:&parameters];
    
    if ([list_identifier length] == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = [NSError errorWithDomain:@"Missing identifier" code:CCMissingIdentifier userInfo:nil];
            failureBlock(nil, error);
        });
        return nil;
    }
    
    NSString *url = [NSString stringWithFormat:@"/user/list/%@/", list_identifier];
    return [_apiManager POST:LURL(url) parameters:@{} success:^(NSURLSessionDataTask *task, id responseObject) {
        successBlock();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)removeList:(NSDictionary *)parameters success:(void(^)())successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSString *list_identifier = [self popValueFromDict:@"list" dict:&parameters];
    
    if ([list_identifier length] == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = [NSError errorWithDomain:@"Missing identifier" code:CCMissingIdentifier userInfo:nil];
            failureBlock(nil, error);
        });
        return nil;
    }
    
    NSString *url = [NSString stringWithFormat:@"/user/list/%@/", list_identifier];
    return [_apiManager DELETE:LURL(url) parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        successBlock();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)removeAddress:(NSDictionary *)parameters success:(void(^)())successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSString *address_identifier = [self popValueFromDict:@"address" dict:&parameters];
    
    if ([address_identifier length] == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = [NSError errorWithDomain:@"Missing identifier" code:CCMissingIdentifier userInfo:nil];
            failureBlock(nil, error);
        });
        return nil;
    }
    
    NSString *url = [NSString stringWithFormat:@"/user/address/%@/", address_identifier];
    return [_apiManager DELETE:LURL(url) parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        successBlock();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)addAddressToList:(NSDictionary *)parameters success:(void(^)())successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSString *list_identifier = [self popValueFromDict:@"list" dict:&parameters];
    NSString *address_identifier = [self popValueFromDict:@"address" dict:&parameters];
    
    if ([list_identifier length] == 0 || [address_identifier length] == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = [NSError errorWithDomain:@"Missing identifier" code:CCMissingIdentifier userInfo:nil];
            failureBlock(nil, error);
        });
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"/list/%@/address/%@/", list_identifier, address_identifier];
    return [_apiManager POST:LURL(path) parameters:@{} success:^(NSURLSessionDataTask *task, id responseObject) {
        successBlock();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)removeAddressFromList:(NSDictionary *)parameters success:(void(^)())successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSString *list_identifier = [self popValueFromDict:@"list" dict:&parameters];
    NSString *address_identifier = [self popValueFromDict:@"address" dict:&parameters];
    
    if ([list_identifier length] == 0 || [address_identifier length] == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = [NSError errorWithDomain:@"Missing identifier" code:CCMissingIdentifier userInfo:nil];
            failureBlock(nil, error);
        });
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"/list/%@/address/%@/", list_identifier, address_identifier];
    
    return [_apiManager DELETE:LURL(path) parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
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
    return [_apiManager PUT:LURL(path) parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *response) {
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
    return [_apiManager PUT:LURL(path) parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *response) {
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
    return [_apiManager POST:LURL(path) parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *response) {
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
    return [_apiManager POST:LURL(path) parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *response) {
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

- (NSURLSessionTask *)fetchListsAroundMe:(CLLocationCoordinate2D)coordinates success:(void(^)(NSArray *lists))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSString *geohash = [CCGeohashHelper geohashFromCoordinates:coordinates];
    NSDictionary *parameters = @{@"geohash" : geohash};
    return [_apiManager GET:LURL(@"/discover/listsaroundme/") parameters:parameters success:^(NSURLSessionDataTask *task, NSArray *responses) {
        successBlock(responses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionTask *)fetchGroupsAroundMe:(CLLocationCoordinate2D)coordinates success:(void(^)(NSArray *groups))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSString *geohash = [CCGeohashHelper geohashFromCoordinates:coordinates];
    NSDictionary *parameters = @{@"geohash" : geohash};
    return [_apiManager GET:LURL(@"/discover/groupsaroundme/") parameters:parameters success:^(NSURLSessionDataTask *task, NSArray *responses) {
        successBlock(responses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionTask *)fetchListsForGroup:(NSString *)identifier success:(void(^)(NSArray *lists))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSString *path = [NSString stringWithFormat:@"/discover/listsforgroup/%@/", identifier];
    return [_apiManager GET:LURL(path) parameters:nil success:^(NSURLSessionDataTask *task, NSArray *responses) {
        successBlock(responses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionTask *)searchLists:(NSString *)search success:(void(^)(NSArray *lists))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSDictionary *params = @{@"search" : search};
    return [_apiManager GET:LURL(@"/discover/searchlist/") parameters:params success:^(NSURLSessionDataTask *task, NSArray *responses) {
        successBlock(responses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)fetchInstalledListsWithSuccess:(void(^)(NSArray *lists))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    return [_apiManager GET:LURL(@"/user/list/") parameters:nil success:^(NSURLSessionDataTask *task, NSArray *responses) {
        successBlock(responses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)fetchCompleteListInfos:(NSString *)identifier success:(void(^)(NSDictionary *listInfo))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSString *path = [NSString stringWithFormat:@"/list/%@/", identifier];
    return [_apiManager GET:LURL(path) parameters:nil success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        successBlock(response);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)fetchListZones:(NSString *)identifier success:(void(^)(NSArray *listZones))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSString *path = [NSString stringWithFormat:@"/list/%@/zones/", identifier];
    return [_apiManager GET:LURL(path) parameters:nil success:^(NSURLSessionDataTask *task, NSArray *responses) {
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
    return [_apiManager GET:LURL(path) parameters:parameters success:^(NSURLSessionDataTask *task, NSArray *responses) {
        successBlock(responses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)fetchListEvents:(NSString *)identifier geohash:(NSString *)geohash lastDate:(NSDate *)lastDate success:(void(^)(NSArray *events))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSString *lastDateString = [self stringFromDate:lastDate];
    NSDictionary *parameters = @{@"geohash" : geohash, @"last_date" : lastDateString, @"list" : identifier};
    return [_apiManager GET:LURL(@"/events/") parameters:parameters success:^(NSURLSessionDataTask *task, NSArray *responses) {
        successBlock(responses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)fetchListEvents:(NSString *)identifier lastDate:(NSDate *)lastDate success:(void(^)(NSArray *events))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSString *lastDateString = [self stringFromDate:lastDate];
    NSDictionary *parameters = @{@"last_date" : lastDateString, @"list" : identifier};
    return [_apiManager GET:LURL(@"/events/") parameters:parameters success:^(NSURLSessionDataTask *task, NSArray *responses) {
        successBlock(responses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)fetchListZoneLastEventDate:(NSString *)identifier geohash:(NSString *)geohash success:(void(^)(NSDate *lastEventDate))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSDictionary *parameters = @{@"geohash" : geohash, @"last_date_only" : @YES, @"list" : identifier};
    return [_apiManager GET:LURL(@"/events/") parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *lastEventDateDict) {
        NSDate *date = [self dateFromString:lastEventDateDict[@"last_date"]];
        successBlock(date);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)fetchListLastEventDate:(NSString *)identifier success:(void(^)(NSDate *lastEventDate))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSDictionary *parameters = @{@"last_date_only" : @YES, @"list" : identifier};
    return [_apiManager GET:LURL(@"/events/") parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *lastEventDateDict) {
        NSDate *date = [self dateFromString:lastEventDateDict[@"last_date"]];
        successBlock(date);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)fetchUserLastEventDateWithSuccess:(void(^)(NSDate *lastEventDate))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSDictionary *parameters = @{@"last_date_only" : @YES};
    return [_apiManager GET:LURL(@"/events/") parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *lastEventDateDict) {
        NSDate *date = [self dateFromString:lastEventDateDict[@"last_date"]];
        successBlock(date);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)fetchUserEventsWithLastDate:(NSDate *)lastDate success:(void(^)(NSArray *events))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSString *lastDateString = [self stringFromDate:lastDate];
    NSDictionary *parameters = @{@"last_date" : lastDateString};
    return [_apiManager GET:LURL(@"/events/") parameters:parameters success:^(NSURLSessionDataTask *task, NSArray *responses) {
        successBlock(responses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)fetchAddressesForEventIds:(NSArray *)eventIds list:(NSString *)identifier success:(void(^)(NSArray *addresses))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSDictionary *parameters = @{@"e" : eventIds, @"list" : identifier};
    return [_apiManager GET:LURL(@"/event/address/") parameters:parameters success:^(NSURLSessionDataTask *task, NSArray *responses) {
        successBlock(responses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)fetchAddressMetasForEventIds:(NSArray *)eventIds success:(void(^)(NSArray *addressMetas))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSDictionary *parameters = @{@"e" : eventIds};
    return [_apiManager GET:LURL(@"/event/address_meta/") parameters:parameters success:^(NSURLSessionDataTask *task, NSArray *responses) {
        successBlock(responses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)fetchListMetasForEventIds:(NSArray *)eventIds success:(void(^)(NSArray *listMetas))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSDictionary *parameters = @{@"e" : eventIds};
    return [_apiManager GET:LURL(@"/event/list_meta/") parameters:parameters success:^(NSURLSessionDataTask *task, NSArray *responses) {
        successBlock(responses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)fetchAddressUserDataForEventIds:(NSArray *)eventIds success:(void(^)(NSArray *userDatas))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSDictionary *parameters = @{@"e" : eventIds};
    return [_apiManager GET:LURL(@"/event/address_user_data/") parameters:parameters success:^(NSURLSessionDataTask *task, NSArray *responses) {
        successBlock(responses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)fetchListUserDataForEventIds:(NSArray *)eventIds success:(void(^)(NSArray *userDatas))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSDictionary *parameters = @{@"e" : eventIds};
    return [_apiManager GET:LURL(@"/event/list_user_data/") parameters:parameters success:^(NSURLSessionDataTask *task, NSArray *responses) {
        successBlock(responses);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
        failureBlock(task, error);
    }];
}

- (NSURLSessionDataTask *)fetchListsForEventIds:(NSArray *)eventIds success:(void(^)(NSArray *lists))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock
{
    NSDictionary *parameters = @{@"e" : eventIds};
    return [_apiManager GET:LURL(@"/event/list/") parameters:parameters success:^(NSURLSessionDataTask *task, NSArray *responses) {
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

- (id)errorDescription:(NSURLSessionDataTask *)task error:(NSError *)error {
    if ([task.response isKindOfClass:[NSHTTPURLResponse class]] == NO)
        return nil;
    
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
    NSString *contentType = response.allHeaderFields[@"Content-Type"];
    if ([contentType isEqualToString:@"application/json"] == NO)
        return nil;
    id responseObject = error.userInfo[kCCJSONResponseSerializerWithDataKey];
    return responseObject;
}

@end
