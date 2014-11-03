//
//  CCGeohashHelper.h
//  Linotte
//
//  Created by stant on 14/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

#import <geohash/geohash.h>

#define kCCGeohashHelperNDigits MAX_GEOHASH_LENGTH

@interface CCGeohashHelper : NSObject

+ (NSString *)geohashFromCoordinates:(CLLocationCoordinate2D)coordinates;
+ (CLLocationCoordinate2D)coordinatesFromGeohash:(NSString *)geohashstring;
+ (NSArray *)geohashGridSurroundingCoordinate:(CLLocationCoordinate2D)coordinates radius:(NSInteger)radius digits:(NSUInteger)digits all:(BOOL)all;
+ (NSArray *)calculateAdjacentGeohashes:(NSString *)geohashstring;

@end
