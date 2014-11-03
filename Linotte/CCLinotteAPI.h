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
 * Model returned for public list
 */

@interface CCPublicListModel : NSObject

@property(nonatomic, strong)NSString *identifier;
@property(nonatomic, strong)NSString *name;
@property(nonatomic, strong)NSString *icon;

@end


/**
 * Model returned for list complete infos
 */

@interface CCCompleteListInfoModel : NSObject

@property(nonatomic, strong)NSString *identifier;
@property(nonatomic, strong)NSString *name;
@property(nonatomic, strong)NSString *icon;
@property(nonatomic, strong)NSNumber *numberOfAddresses;
@property(nonatomic, strong)NSNumber *numberOfInstalls;
@property(nonatomic, strong)NSDate *lastUpdate;
@property(nonatomic, strong)NSString *author;
@property(nonatomic, strong)NSString *authorId;

@end

/**
 * Model returned for list geohash zones
 */

@interface CCListGeohashZoneModel : NSObject

@property(nonatomic, strong)NSString *geohash;
@property(nonatomic, strong)NSNumber *nAddresses;

@end

/**
 * Model returned for address fetch
 */

@interface CCAddressModel : NSObject

@property(nonatomic, strong)NSString *identifier;
@property(nonatomic, strong)NSNumber *latitude;
@property(nonatomic, strong)NSNumber *longitude;
@property(nonatomic, strong)NSString *name;
@property(nonatomic, strong)NSString *address;
@property(nonatomic, strong)NSString *provider;
@property(nonatomic, strong)NSString *providerId;
@property(nonatomic, strong)NSDate *dateCreated;
@property(nonatomic, strong)NSString *note;
@property(nonatomic, strong)NSNumber *notification;

@end

/**
 * Model returned for event fetch
 */

@interface CCServerEventModel : NSObject

@property(nonatomic, strong)NSNumber *id;
@property(nonatomic, strong)NSNumber *event;
@property(nonatomic, strong)NSString *objectIdentifier;

@end


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

- (void)createAddress:(CCAddress *)address completionBlock:(void(^)(BOOL success))completionBlock;
- (void)createList:(CCList *)list completionBlock:(void(^)(BOOL success))completionBlock;

- (void)addList:(CCList *)list completionBlock:(void(^)(BOOL success))completionBlock;
- (void)removeList:(NSString *)identifier completionBlock:(void(^)(BOOL success))completionBlock;
- (void)removeAddress:(NSString *)identifier completionBlock:(void(^)(BOOL success))completionBlock;

- (void)addAddress:(CCAddress *)address toList:(CCList *)list completionBlock:(void(^)(BOOL success))completionBlock;
- (void)removeAddress:(CCAddress *)address fromList:(CCList *)list completionBlock:(void(^)(BOOL success))completionBlock;

- (void)updateAddress:(CCAddress *)address completionBlock:(void(^)(BOOL success))completionBlock;
- (void)updateList:(CCList *)list completionBlock:(void(^)(BOOL success))completionBlock;

- (void)updateAddressUserData:(CCAddress *)address completionBlock:(void(^)(BOOL success))completionBlock;

#pragma mark - Fetch methods

- (void)fetchPublicLists:(CLLocationCoordinate2D)coordinates completionBlock:(void(^)(BOOL success, NSArray *lists))completionBlock;
- (void)fetchCompleteListInfos:(NSString *)identifier completionBlock:(void(^)(BOOL success, CCCompleteListInfoModel *completeListInfoModel))completionBlock;
- (void)fetchListZones:(NSString *)identifier completionBlock:(void(^)(BOOL success, NSArray *listZones))completionBlock;
- (void)fetchAddressesFromList:(NSString *)identifier geohash:(NSString *)geohash lastAddressDate:(NSDate *)lastAddressDate limit:(NSUInteger)limit completionBlock:(void(^)(BOOL success, NSArray *addresses))completionBlock;
- (void)fetchListEvents:(NSString *)identifier geohash:(NSString *)geohash lastId:(NSNumber *)lastId completionBlock:(void(^)(BOOL success, NSArray *events))completionBlock;

+ (instancetype)sharedInstance;

@end
