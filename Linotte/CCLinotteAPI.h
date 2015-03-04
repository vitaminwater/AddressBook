//
//  CCAdRemSDK.h
//  AdRem
//
//  Created by stant on 13/04/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class CCAddress;
@class CCList;
@class RKPaginator;

typedef enum : NSUInteger {
    CCMissingIdentifier = 424200,
} CCLinotteAPIErrorCodes;

/**
 * CCLinotteAPI interface
 */

@interface CCLinotteAPI : NSObject

- (instancetype)initWithClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret;

- (void)setAuthHTTPHeader:(NSString *)accessToken;
- (void)unsetAuthHttpHeader;

- (NSURLSessionDataTask *)authenticate:(NSDictionary *)parameters success:(void(^)(NSString *identifier, NSString *accessToken, NSString *authMethodIdentifier))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock;

- (NSURLSessionDataTask *)createUser:(NSDictionary *)parameters success:(void(^)(NSString *identifier, NSString *accessToken, NSString *authMethodIdentifier))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock;
- (NSURLSessionDataTask *)addAuthenticationMethod:(NSDictionary *)parameters success:(void(^)(NSString *identifier))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock;

- (NSURLSessionDataTask *)createDeviceWithSuccess:(void(^)(NSString *deviceId))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock;
- (NSURLSessionDataTask *)sendDevicePushNotificationToken:(NSString *)token success:(void(^)())successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock;
- (void)setDeviceHTTPHeader:(NSString *)deviceId;
- (void)unsetDeviceHTTPHeader;

- (NSString *)UUID:(NSUInteger)len;

#pragma mark - Data management methods

- (NSURLSessionDataTask *)createAddress:(NSDictionary *)parameters success:(void(^)(NSString *identifier, NSInteger statusCode))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock;
- (NSURLSessionDataTask *)createAddressMeta:(NSDictionary *)parameters success:(void(^)())successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock;
- (NSURLSessionDataTask *)createList:(NSDictionary *)parameters success:(void(^)(NSString *identifier))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock;
- (NSURLSessionDataTask *)addList:(NSDictionary *)parameters success:(void(^)())successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock;
- (NSURLSessionDataTask *)removeList:(NSDictionary *)parameters success:(void(^)())successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock;
- (NSURLSessionDataTask *)removeAddress:(NSDictionary *)parameters success:(void(^)())successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock;
- (NSURLSessionDataTask *)addAddressToList:(NSDictionary *)parameters success:(void(^)())successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock;
- (NSURLSessionDataTask *)removeAddressFromList:(NSDictionary *)parameters success:(void(^)())successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock;
- (NSURLSessionDataTask *)updateAddress:(NSDictionary *)parameters success:(void(^)())successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock;
- (NSURLSessionDataTask *)updateList:(NSDictionary *)parameters success:(void(^)())successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock;
- (NSURLSessionDataTask *)updateAddressUserData:(NSDictionary *)parameters success:(void(^)())successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock;
- (NSURLSessionDataTask *)updateListUserData:(NSDictionary *)parameters success:(void(^)())successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock;

#pragma mark - Fetch methods

- (NSURLSessionTask *)fetchListsAroundMe:(CLLocationCoordinate2D)coordinates success:(void(^)(NSArray *lists))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock;
- (NSURLSessionTask *)fetchGroupsAroundMe:(CLLocationCoordinate2D)coordinates success:(void(^)(NSArray *groups))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock;
- (NSURLSessionTask *)fetchListsForGroup:(NSString *)identifier success:(void(^)(NSArray *lists))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock;
- (NSURLSessionTask *)searchLists:(NSString *)search success:(void(^)(NSArray *lists))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock;
- (NSURLSessionDataTask *)fetchInstalledListsWithSuccess:(void(^)(NSArray *lists))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock;
- (NSURLSessionDataTask *)fetchCompleteListInfos:(NSString *)identifier success:(void(^)(NSDictionary *listInfo))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock;
- (NSURLSessionDataTask *)fetchListZones:(NSString *)identifier success:(void(^)(NSArray *listZones))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock;
- (NSURLSessionDataTask *)fetchAddressesFromList:(NSString *)identifier geohash:(NSString *)geohash lastAddressDate:(NSDate *)lastAddressDate limit:(NSUInteger)limit success:(void(^)(NSArray *addresses))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock;
- (NSURLSessionDataTask *)fetchListEvents:(NSString *)identifier geohash:(NSString *)geohash lastDate:(NSDate *)lastDate success:(void(^)(NSArray *events))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock;
- (NSURLSessionDataTask *)fetchListEvents:(NSString *)identifier lastDate:(NSDate *)lastDate success:(void(^)(NSArray *events))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock;
- (NSURLSessionDataTask *)fetchListZoneLastEventDate:(NSString *)identifier geohash:(NSString *)geohash success:(void(^)(NSDate *lastEventDate))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock;
- (NSURLSessionDataTask *)fetchListLastEventDate:(NSString *)identifier success:(void(^)(NSDate *lastEventDate))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock;
- (NSURLSessionDataTask *)fetchUserLastEventDateWithSuccess:(void(^)(NSDate *lastEventDate))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock;
- (NSURLSessionDataTask *)fetchUserEventsWithLastDate:(NSDate *)lastDate success:(void(^)(NSArray *events))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock;
- (NSURLSessionDataTask *)fetchAddressesForEventIds:(NSArray *)eventIds list:(NSString *)identifier success:(void(^)(NSArray *addresses))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock;
- (NSURLSessionDataTask *)fetchAddressMetasForEventIds:(NSArray *)eventIds success:(void(^)(NSArray *addressMetas))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock;
- (NSURLSessionDataTask *)fetchListMetasForEventIds:(NSArray *)eventIds success:(void(^)(NSArray *listMetas))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock;
- (NSURLSessionDataTask *)fetchAddressUserDataForEventIds:(NSArray *)eventIds success:(void(^)(NSArray *userDatas))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock;
- (NSURLSessionDataTask *)fetchListUserDataForEventIds:(NSArray *)eventIds success:(void(^)(NSArray *userDatas))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock;
- (NSURLSessionDataTask *)fetchListsForEventIds:(NSArray *)eventIds success:(void(^)(NSArray *lists))successBlock failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failureBlock;

#pragma mark - Date conversion methods

- (NSString *)stringFromDate:(NSDate *)date;
- (NSDate *)dateFromString:(NSString *)dateString;

#pragma mark - error handling helper methods

- (id)errorDescription:(NSURLSessionDataTask *)task error:(NSError *)error;

@end
