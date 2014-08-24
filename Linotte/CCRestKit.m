//
//  CCRestKit.m
//  Local
//
//  Created by stant on 20/01/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCRestKit.h"

#import "CCGoogleAutocomplete.h"
#import "CCGooglePrediction.h"

#import "CCGoogleSearch.h"
#import "CCGoogleSearchResult.h"

#import "CCGoogleGeocode.h"
#import "CCGoogleGeocodeResult.h"

#import "CCGoogleDetail.h"
#import "CCGoogleDetailResult.h"

#import "CCFoursquareVenues.h"
#import "CCFoursquareCategorie.h"

#import "CCOAuthTokenResponse.h"
#import "CCOAuthTokenRequest.h"

#import "CCUserPostPutRequest.h"
#import "CCUserPostPutResponse.h"

#import "CCAddress.h"

#define kGooglePlaceBaseUrl @"https://maps.googleapis.com"
#define kFoursquareBaseUrl @"https://api.foursquare.com"

#if defined DEBUG
// #define kCCLocalApiServerUrl @"https://172.20.10.14:8001" // iOS
// #define kCCLocalApiServerUrl @"https://192.168.11.111:8001" // Numa
// #define kCCLocalApiServerUrl @"https://192.168.1.13:8001" // Pereire
#define kCCLocalApiServerUrl @"https://192.168.1.93:8001" // La clef
#else
#define kCCLocalApiServerUrl @"http://www.getlinotte.com"
#endif

@implementation CCRestKit

#pragma mark - RKObjectManager methods

NSMutableDictionary *_objectManagers = nil;

+ (RKObjectManager *)addObjectManager:(NSString *)name baseUrl:(NSString *)baseUrl addManagedObjectStore:(BOOL)addManagedObjectStore mimeType:(NSString *)mimeTypeSerialization
{
    if (_objectManagers == nil)
        _objectManagers = [@{} mutableCopy];
    RKObjectManager *objectManager = _objectManagers[name];
    if (objectManager == nil) {
        objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:baseUrl]];
        
        if (addManagedObjectStore)
            objectManager.managedObjectStore = [RKManagedObjectStore defaultStore];
        
        [objectManager setRequestSerializationMIMEType:mimeTypeSerialization];
        
#if defined(DEBUG)
        objectManager.HTTPClient.allowsInvalidSSLCertificate = YES;
#endif
        
        _objectManagers[name] = objectManager;
    }
    return objectManager;
}

+ (RKObjectManager *)getObjectManager:(NSString *)name
{
    NSAssert(_objectManagers, @"call addObjectManager first !!!!");
    NSAssert(_objectManagers[name], @"No RKObjectManager by that name here...");
    
    return _objectManagers[name];
}

#pragma mark - store path

+ (NSString *)storePath
{
    return [RKApplicationDataDirectory() stringByAppendingPathComponent:@"db.sqlite"];
}

#pragma mark - mapping methods

+ (void)initializeMappings
{
    //RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
    //RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    
    [self initializeGoogleAutocompleteMapping];
    [self initializeGoogleSearchMapping];
    [self initializeGoogleDetailMapping];
    [self initializeGoogleGeocodeMapping];
    
    [self initializeFoursquareMapping];
    
    [self initializeOAuthMapping];
    [self initializeUserPostPutMapping];
    [self initializeCoreDataMappings];
}

#pragma mark Google API

+ (void)initializeGoogleAutocompleteMapping
{
    RKObjectManager *objectManager = [self addObjectManager:kCCGooglePlaceObjectManager baseUrl:kGooglePlaceBaseUrl addManagedObjectStore:NO mimeType:RKMIMETypeFormURLEncoded];
    
    RKObjectMapping *autocompleteMapping = [RKObjectMapping mappingForClass:[CCGoogleAutocomplete class]];
    [autocompleteMapping addAttributeMappingsFromArray:@[@"status"]];
    
    RKObjectMapping *predictionMapping = [RKObjectMapping mappingForClass:[CCGooglePrediction class]];
    [predictionMapping addAttributeMappingsFromDictionary:@{@"description" : @"description", @"id" : @"identifier", @"reference" : @"reference"}];
    
    [autocompleteMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"predictions" toKeyPath:@"predictions" withMapping:predictionMapping]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:autocompleteMapping method:RKRequestMethodGET pathPattern:kCCGoogleMapsAPIAutocomplete keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    [objectManager addResponseDescriptor:responseDescriptor];
}

+ (void)initializeGoogleSearchMapping
{
    RKObjectManager *objectManager = [self addObjectManager:kCCGooglePlaceObjectManager baseUrl:kGooglePlaceBaseUrl addManagedObjectStore:NO mimeType:RKMIMETypeFormURLEncoded];
    
    RKObjectMapping *searchResultMapping = [RKObjectMapping mappingForClass:[CCGoogleSearchResult class]];
    [searchResultMapping addAttributeMappingsFromDictionary:@{@"vicinity" : @"formattedAddress", @"geometry.location.lat" : @"latitude", @"geometry.location.lng" : @"longitude", @"icon" : @"icon", @"id" : @"identifier", @"name" : @"name", @"reference" : @"reference", @"types" : @"types"}];
    
    RKObjectMapping *searchMapping = [RKObjectMapping mappingForClass:[CCGoogleSearch class]];
    [searchMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"results" toKeyPath:@"results" withMapping:searchResultMapping]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:searchMapping method:RKRequestMethodGET pathPattern:kCCGoogleMapsAPINearbySearch keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    [objectManager addResponseDescriptor:responseDescriptor];
}

+ (void)initializeGoogleDetailMapping
{
    RKObjectManager *objectManager = [self addObjectManager:kCCGooglePlaceObjectManager baseUrl:kGooglePlaceBaseUrl addManagedObjectStore:NO mimeType:RKMIMETypeFormURLEncoded];
    
    RKObjectMapping *detailResultMapping = [RKObjectMapping mappingForClass:[CCGoogleDetailResult class]];
    [detailResultMapping addAttributeMappingsFromDictionary:@{@"formatted_address" : @"formattedAddress", @"geometry.location.lat" : @"latitude", @"geometry.location.lng" : @"longitude"}];
    
    RKObjectMapping *detailMapping = [RKObjectMapping mappingForClass:[CCGoogleDetail class]];
    [detailMapping addRelationshipMappingWithSourceKeyPath:@"result" mapping:detailResultMapping];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:detailMapping method:RKRequestMethodGET pathPattern:kCCGoogleMapsAPIPlaceDetail keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    [objectManager addResponseDescriptor:responseDescriptor];
}

+ (void)initializeGoogleGeocodeMapping
{
    RKObjectManager *objectManager = [self addObjectManager:kCCGooglePlaceObjectManager baseUrl:kGooglePlaceBaseUrl addManagedObjectStore:NO mimeType:RKMIMETypeFormURLEncoded];
    
    RKObjectMapping *geocodeResultMapping = [RKObjectMapping mappingForClass:[CCGoogleGeocodeResult class]];
    [geocodeResultMapping addAttributeMappingsFromDictionary:@{@"formatted_address" : @"formattedAddress", @"geometry.location.lat" : @"latitude", @"geometry.location.lng" : @"longitude"}];

    RKObjectMapping *geocodeMapping = [RKObjectMapping mappingForClass:[CCGoogleGeocode class]];
    [geocodeMapping addRelationshipMappingWithSourceKeyPath:@"results" mapping:geocodeResultMapping];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:geocodeMapping method:RKRequestMethodGET pathPattern:kCCGoogleMapsAPIGeocode keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    [objectManager addResponseDescriptor:responseDescriptor];
}

#pragma mark - Foursquare

+ (void)initializeFoursquareMapping
{
    RKObjectManager *objectManager = [self addObjectManager:kCCFoursquareObjectManager baseUrl:kFoursquareBaseUrl addManagedObjectStore:NO mimeType:RKMIMETypeFormURLEncoded];
    
    RKObjectMapping *venuesMapping = [RKObjectMapping mappingForClass:[CCFoursquareVenues class]];
    [venuesMapping addAttributeMappingsFromDictionary:@{@"name" : @"name", @"location.lat" : @"latitude", @"location.lng" : @"longitude", @"location.address" : @"address", @"location.city" : @"city", @"location.country" : @"country"}];
    
    RKObjectMapping *categoriesMapping = [RKObjectMapping mappingForClass:[CCFoursquareCategorie class]];
    [categoriesMapping addAttributeMappingsFromDictionary:@{@"id" : @"identifier", @"name" : @"name"}];
    
    [venuesMapping addRelationshipMappingWithSourceKeyPath:@"categories" mapping:categoriesMapping];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:venuesMapping method:RKRequestMethodGET pathPattern:kCCFoursquareAPIVenueSearch keyPath:@"response.venues" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    [objectManager addResponseDescriptor:responseDescriptor];
}

#pragma mark - Local API

+ (void)initializeOAuthMapping
{
    RKObjectManager *objectManager = [self addObjectManager:kCCLocalUrlEncodedObjectManager baseUrl:kCCLocalApiServerUrl addManagedObjectStore:NO mimeType:RKMIMETypeFormURLEncoded];
    
    /* Token request response mapping */
    RKObjectMapping *oauthResponseMapping = [RKObjectMapping mappingForClass:[CCOAuthTokenResponse class]];
    [oauthResponseMapping addAttributeMappingsFromDictionary:@{@"access_token" : @"accessToken", @"refresh_token" : @"refreshToken"}];

    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:oauthResponseMapping method:RKRequestMethodPOST pathPattern:kCCLocalAPIAccessToken keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    [objectManager addResponseDescriptor:responseDescriptor];
    
    /* Token request request mapping */
    RKObjectMapping *oauthTokenRequestMapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    [oauthTokenRequestMapping addAttributeMappingsFromDictionary:@{@"clientId" : @"client_id", @"clientSecret" : @"client_secret", @"grantType" : @"grant_type", @"scope" : @"scope", @"username" : @"username", @"password" : @"password", @"refreshToken" : @"refresh_token"}];
    
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:oauthTokenRequestMapping objectClass:[CCOAuthTokenRequest class] rootKeyPath:nil method:RKRequestMethodPOST];
    [objectManager addRequestDescriptor:requestDescriptor];
}

+ (void)initializeUserPostPutMapping
{
    RKObjectManager *objectManager = [self addObjectManager:kCCLocalJSONObjectManager baseUrl:kCCLocalApiServerUrl addManagedObjectStore:YES mimeType:RKMIMETypeJSON];
    
    /* User creation/modification response */
    RKObjectMapping *userPostPutResponseMapping = [RKObjectMapping mappingForClass:[CCUserPostPutResponse class]];
    [userPostPutResponseMapping addAttributeMappingsFromArray:@[@"identifier"]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userPostPutResponseMapping method:RKRequestMethodPOST | RKRequestMethodPUT | RKRequestMethodPATCH pathPattern:kCCLocalAPIUser keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    /* User creation/modification request */
    RKObjectMapping *userPostPutRequestMapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    [userPostPutRequestMapping addAttributeMappingsFromDictionary:@{@"password" : @"password", @"username" : @"username", @"firstName" : @"first_name", @"lastName" : @"last_name", @"email" : @"email", @"isNewUser" : @"is_new_user"}];
    
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:userPostPutRequestMapping objectClass:[CCUserPostPutRequest class] rootKeyPath:nil method:RKRequestMethodPOST | RKRequestMethodPUT | RKRequestMethodPATCH];
    
    [objectManager addRequestDescriptor:requestDescriptor];
}

+ (void)initializeCoreDataMappings
{
    RKObjectManager *objectManager = [self addObjectManager:kCCLocalJSONObjectManager baseUrl:kCCLocalApiServerUrl addManagedObjectStore:YES mimeType:RKMIMETypeJSON];
    
    /* CCAddress mapping */
    {
        RKObjectMapping *requestEntityMapping = [CCAddress requestObjectMapping];
        
        RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestEntityMapping objectClass:[CCAddress class] rootKeyPath:nil method:RKRequestMethodPOST];
        
        [objectManager addRequestDescriptor:requestDescriptor];

        RKEntityMapping *responseEntityMapping = [CCAddress responseEntityMapping];
        
        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseEntityMapping method:RKRequestMethodPOST pathPattern:kCCLocalAPIAddress keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        
        [objectManager addResponseDescriptor:responseDescriptor];
    }
}

@end
