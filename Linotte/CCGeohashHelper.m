//
//  CCGeohashHelper.m
//  Linotte
//
//  Created by stant on 14/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCGeohashHelper.h"

NSArray *geohashLimit(CLLocation *location, NSUInteger digits) // TODO cache result
{
    NSArray *geohashes = [CCGeohashHelper geohashGridSurroundingCoordinate:location.coordinate radius:1 digits:digits all:YES];
    NSMutableArray *geohashesComp = [@[] mutableCopy];
    for (NSString *geohash in geohashes) {
        NSString *subGeohash = [geohash substringToIndex:digits];
        [geohashesComp addObject:subGeohash];
    }
    return geohashesComp;
}

@implementation CCGeohashHelper

+ (NSString *)geohashFromCoordinates:(CLLocationCoordinate2D)coordinates
{
    CCGeohashStruct geohash = {
        .latitude = coordinates.latitude,
        .longitude = coordinates.longitude
    };
    init_from_coordinates(&geohash);
    return @(geohash.hash);
}

+ (CLLocationCoordinate2D)coordinatesFromGeohash:(NSString *)geohashstring
{
    NSAssert([geohashstring length] <= kCCGeohashHelperNDigits, @"Wrong geohash length");
    CCGeohashStruct geohash = {};
    memset(geohash.hash, '0', kCCGeohashHelperNDigits);
    strncpy(geohash.hash, [geohashstring UTF8String], strlen([geohashstring UTF8String]));
    init_from_hash(&geohash);
    
    return CLLocationCoordinate2DMake(geohash.latitude, geohash.longitude);
}

// when parameter "all" is NO, returns the grid for geohash monitoring
+ (NSArray *)geohashGridSurroundingCoordinate:(CLLocationCoordinate2D)coordinates radius:(NSInteger)radius digits:(NSUInteger)digits all:(BOOL)all
{
    NSMutableArray *geohashes = [@[] mutableCopy];
    CCGeohashStruct centerGeohash = {
        .latitude = coordinates.latitude,
        .longitude = coordinates.longitude
    };
    init_from_coordinates(&centerGeohash);

    digits = MIN(digits, kCCGeohashHelperNDigits);
    NSUInteger power = kCCGeohashHelperNDigits - digits;
    NSUInteger digitsToMultiplier = pow(2, power);
    for (NSInteger i = -radius; i <= radius; ++i) {
        
        for (NSInteger j = -radius; j <= radius; ++j) {
            
            if (all || !((!i && !j) || ((i == j || i == -j) && abs((int)i) == radius))) {
                CCGeohashStruct geohash = init_neighbour(&centerGeohash, (int)(j * digitsToMultiplier), (int)(i * digitsToMultiplier));
                NSString *hash = [@(geohash.hash) substringToIndex:digits];
                [geohashes addObject:hash];
            }
        }
        
    }
    
    return geohashes;
}

+ (NSArray *)calculateAdjacentGeohashes:(NSString *)geohashstring
{
    NSAssert([geohashstring length] == kCCGeohashHelperNDigits, @"Wrong geohash length");
    NSMutableArray *results = [@[geohashstring] mutableCopy];
    CCGeohashStruct geohash = {};
    strncpy(geohash.hash, [geohashstring UTF8String], kCCGeohashHelperNDigits + 1);
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
