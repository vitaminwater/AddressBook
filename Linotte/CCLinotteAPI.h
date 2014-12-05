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
    kCCFirstStart, // When nothing has happened yet
    kCCLoggedIn, // When everything is fine
    kCCRequestRefreshToken, // When access token is outdated
    kCCCreateDeviceId, // When upgrading from 1.0 to 2.0, device is not created yet
    kCCFailed, // unknown error
} CCLoggedState;

/**
 * CCLinotteAPI interface
 */

@interface CCLinotteAPI : NSObject

@property(nonatomic, strong)NSString *identifier;
@property(nonatomic, readonly)CCLoggedState loggedState;

- (void)setClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret;

- (void)APIIinitialization:(void(^)(CCLoggedState fromState))stateStepBlock completionBock:(void(^)(BOOL success))completionBlock;

- (void)authenticate:(NSString *)username password:(NSString *)password completionBlock:(void(^)(BOOL success))completionBlock;
- (void)refreshTokenWithCompletionBlock:(void(^)(BOOL success))completionBlock;

- (void)createAndAuthenticateAnonymousUserWithCompletionBlock:(void(^)(BOOL success))completionBlock;

#pragma mark - Data management methods

- (void)createAddress:(NSDictionary *)parameters completionBlock:(void(^)(BOOL success, NSString *identifier, NSInteger statusCode))completionBlock;
- (void)createAddressMeta:(NSDictionary *)parameters completionBlock:(void(^)(BOOL success, NSInteger statusCode))completionBlock;
- (void)createList:(NSDictionary *)parameters completionBlock:(void(^)(BOOL success, NSString *identifier, NSInteger statusCode))completionBlock;

- (void)addList:(NSDictionary *)parameters completionBlock:(void(^)(BOOL success, NSInteger statusCode))completionBlock;
- (void)removeList:(NSDictionary *)parameters completionBlock:(void(^)(BOOL success, NSInteger statusCode))completionBlock;
- (void)removeAddress:(NSDictionary *)parameters completionBlock:(void(^)(BOOL success, NSInteger statusCode))completionBlock;

- (void)addAddressToList:(NSDictionary *)parameters completionBlock:(void(^)(BOOL success, NSInteger statusCode))completionBlock;
- (void)removeAddressFromList:(NSDictionary *)parameters completionBlock:(void(^)(BOOL success, NSInteger statusCode))completionBlock;

- (void)updateAddress:(NSDictionary *)parameters completionBlock:(void(^)(BOOL success, NSInteger statusCode))completionBlock;
- (void)updateList:(NSDictionary *)parameters completionBlock:(void(^)(BOOL success, NSInteger statusCode))completionBlock;

- (void)updateAddressUserData:(NSDictionary *)parameters completionBlock:(void(^)(BOOL success, NSInteger statusCode))completionBlock;
- (void)updateListUserData:(NSDictionary *)parameters completionBlock:(void(^)(BOOL success, NSInteger statusCode))completionBlock;

#pragma mark - Fetch methods

- (NSURLSessionTask *)fetchPublicLists:(CLLocationCoordinate2D)coordinates completionBlock:(void(^)(BOOL success, NSArray *lists))completionBlock;
- (NSURLSessionTask *)fetchInstalledListsWithCompletionBlock:(void(^)(BOOL success, NSArray *lists))completionBlock;
- (NSURLSessionTask *)fetchCompleteListInfos:(NSString *)identifier completionBlock:(void(^)(BOOL success, NSDictionary *listInfo))completionBlock;
- (NSURLSessionTask *)fetchListZones:(NSString *)identifier completionBlock:(void(^)(BOOL success, NSArray *listZones))completionBlock;
- (NSURLSessionTask *)fetchAddressesFromList:(NSString *)identifier geohash:(NSString *)geohash lastAddressDate:(NSDate *)lastAddressDate limit:(NSUInteger)limit completionBlock:(void(^)(BOOL success, NSArray *addresses))completionBlock;
- (NSURLSessionTask *)fetchListEvents:(NSString *)identifier geohash:(NSString *)geohash lastDate:(NSDate *)lastDate completionBlock:(void(^)(BOOL success, NSArray *events))completionBlock;
- (NSURLSessionTask *)fetchListEvents:(NSString *)identifier lastDate:(NSDate *)lastDate completionBlock:(void(^)(BOOL success, NSArray *events))completionBlock;
- (NSURLSessionTask *)fetchListZoneLastEventDate:(NSString *)identifier geohash:(NSString *)geohash completionBlock:(void(^)(BOOL success, NSDate *lastEventDate))completionBlock;
- (NSURLSessionTask *)fetchListLastEventDate:(NSString *)identifier completionBlock:(void(^)(BOOL success, NSDate *lastEventDate))completionBlock;
- (NSURLSessionTask *)fetchUserLastEventDateWithCompletionBlock:(void(^)(BOOL success, NSDate *lastEventDate))completionBlock;
- (NSURLSessionTask *)fetchUserEventsWithLastDate:(NSDate *)lastDate completionBlock:(void(^)(BOOL success, NSArray *events))completionBlock;
- (NSURLSessionTask *)fetchAddressesForEventIds:(NSArray *)eventIds list:(NSString *)identifier completionBlock:(void(^)(BOOL success, NSArray *addresses))completionBlock;
- (NSURLSessionTask *)fetchAddressMetasForEventIds:(NSArray *)eventIds completionBlock:(void(^)(BOOL success, NSArray *addressMetas))completionBlock;
- (NSURLSessionTask *)fetchListMetasForEventIds:(NSArray *)eventIds completionBlock:(void(^)(BOOL success, NSArray *listMetas))completionBlock;
- (NSURLSessionTask *)fetchAddressUserDataForEventIds:(NSArray *)eventIds completionBlock:(void(^)(BOOL success, NSArray *userDatas))completionBlock;
- (NSURLSessionTask *)fetchListUserDataForEventIds:(NSArray *)eventIds completionBlock:(void(^)(BOOL success, NSArray *userDatas))completionBlock;
- (NSURLSessionTask *)fetchListsForEventIds:(NSArray *)eventIds completionBlock:(void(^)(BOOL success, NSArray *userDatas))completionBlock;

#pragma mark - Date conversion methods

- (NSString *)stringFromDate:(NSDate *)date;
- (NSDate *)dateFromString:(NSString *)dateString;

+ (instancetype)sharedInstance;

@end
