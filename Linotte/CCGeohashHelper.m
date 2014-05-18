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

+ (CLLocationCoordinate2D)coordinatesFromGeohash:(NSString *)hash
{
    NSAssert([hash length] <= MAX_GEOHASH_LENGTH, @"Wrong geohash length");
    CCGeohashStruct geohash = {};
    strncpy(geohash.hash, [hash UTF8String], MAX_GEOHASH_LENGTH + 1);
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

@end
