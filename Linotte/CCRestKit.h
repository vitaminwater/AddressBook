//
//  CCRestKit.h
//  Local
//
//  Created by stant on 20/01/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <RestKit/RestKit.h>

#define kCCGooglePlaceObjectManager @"kGooglePlaceObjectManager"
#define kCCFoursquareObjectManager @"kFoursquareObjectManager"
#define kCCLocalUrlEncodedObjectManager @"kCCLocalUrlEncodedObjectManager"
#define kCCLocalJSONObjectManager @"kCCLocalJSONObjectManager"

#define kCCGoogleMapsAPIAutocomplete @"/maps/api/place/autocomplete/json"
#define kCCGoogleMapsAPINearbySearch @"/maps/api/place/nearbysearch/json"
#define kCCGoogleMapsAPIPlaceDetail @"/maps/api/place/details/json"
#define kCCGoogleMapsAPIGeocode @"/maps/api/geocode/json"

#define kCCFoursquareAPIVenueSearch @"/v2/venues/search"

#define kCCLocalAPIAccessToken @"/api/oauth2/access_token/"
#define kCCLocalAPIUser @"/api/user/"
#define kCCLocalAPIAddress @"/api/address/"
#define kCCLocalAPIList @"/api/list/"

@class RKObjectManager;

@interface CCRestKit : NSObject

+ (RKObjectManager *)getObjectManager:(NSString *)name;

+ (NSString *)storePath;

+ (void)initializeMappings;

@end
