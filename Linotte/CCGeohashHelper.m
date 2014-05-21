//
//  CCGeohashHelper.m
//  Linotte
//
//  Created by stant on 14/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCGeohashHelper.h"

#import <geohash/geohash.h>

@implementation CCGeohashHelper

+ (NSString *)geohashFromCoordinates:(CLLocationCoordinate2D)coordinates
{
    CCGeohashStruct geohash = {
        coordinates.latitude,
        coordinates.longitude
    };
    init_from_coordinates(&geohash);
    return @(geohash.hash);
}

+ (CLLocationCoordinate2D)coordinatesFromGeohash:(NSString *)geohashstring
{
    NSAssert([geohashstring length] <= MAX_GEOHASH_LENGTH, @"Wrong geohash length");
    CCGeohashStruct geohash = {};
    strncpy(geohash.hash, [geohashstring UTF8String], MAX_GEOHASH_LENGTH + 1);
    init_from_hash(&geohash);
    
    return CLLocationCoordinate2DMake(geohash.latitude, geohash.longitude);
}

+ (NSArray *)geohashGridSurroundingCoordinate:(CLLocationCoordinate2D)coordinates
{
    NSMutableArray *geohashes = [@[] mutableCopy];
    CCGeohashStruct centerGeohash = {
        coordinates.latitude,
        coordinates.longitude
    };
    init_from_coordinates(&centerGeohash);

    for (int i = -2; i <= 2; ++i) {
        
        for (int j = -2; j <= 2; ++j) {
            
            if (!((!i && !j) || ((i == j || i == -j) && abs(i) == 2))) {
                CCGeohashStruct geohash = init_neighbour(&centerGeohash, j, i);
                NSString *hash = @(geohash.hash);
                [geohashes addObject:hash];
                //NSLog(@"i: %d  j: %d  geohash: %@  lat: %f  lng: %f", i, j, hash, geohash.latitude, geohash.longitude);
            }
        }
        
    }
    
    return geohashes;
}

+ (NSArray *)calculateAdjacentGeohashesFromcoordinates:(CLLocationCoordinate2D)coordinates
{
    NSMutableArray *results = [@[] mutableCopy];
    CCGeohashStruct geohash = {
        coordinates.latitude,
        coordinates.longitude
    };
    init_from_coordinates(&geohash);
    
    init_from_coordinates(&geohash);
    
    [results addObject:@(geohash.hash)];
    
    BOOL latitude = geohash.latitude < coordinates.latitude;
    BOOL longitude = geohash.longitude < coordinates.longitude;
    
    init_neighbour(&geohash, latitude ? 1 : -1, 0);
    [results addObject:@(geohash.hash)];
    
    init_neighbour(&geohash, 0, longitude ? 1 : -1);
    [results addObject:@(geohash.hash)];

    init_neighbour(&geohash, latitude ? 1 : -1, longitude ? 1 : -1);
    [results addObject:@(geohash.hash)];
    
    return results;
}

+ (NSArray *)calculateAdjacentGeohashes:(NSString *)geohashstring
{
    NSAssert([geohashstring length] <= MAX_GEOHASH_LENGTH, @"Wrong geohash length");
    NSMutableArray *results = [@[geohashstring] mutableCopy];
    CCGeohashStruct geohash = {};
    strncpy(geohash.hash, [geohashstring UTF8String], MAX_GEOHASH_LENGTH + 1);
    init_from_hash(&geohash);
    
    for (int i = 0; i < 3; ++i) {
        for (int j = 0; j < 3; ++j) {
            if (i && j && i == j)
                continue;
            CCGeohashStruct tmp = init_neighbour(&geohash, i - 1, j - 1);
            [results addObject:@(tmp.hash)];
        }
    }
    
    return results;
}

@end
