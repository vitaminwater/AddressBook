//
//  CCGeohashHelper.h
//  Linotte
//
//  Created by stant on 14/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

@interface CCGeohashHelper : NSObject

+ (NSString *)geohashFromCoordinates:(CLLocationCoordinate2D)coordinates;
+ (CLLocationCoordinate2D)coordinatesFromGeohash:(NSString *)hash;
+ (NSArray *)geohashGridSurroundingCoordinate:(CLLocationCoordinate2D)coordinates;

@end
