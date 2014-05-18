//
//  CCOutputViewDelegate.h
//  Linotte
//
//  Created by stant on 12/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    CCRouteTypeWalk,
    CCRouteTypeCar,
    CCRouteTypeTrain,
    CCRouteTypeBicycling
} CCRouteType;

@protocol CCOutputViewDelegate <NSObject>

- (void)launchRoute:(CCRouteType)type;

- (double)addressDistance;
- (NSString *)addressName;
- (NSString *)addressString;
- (double)addressLatitude;
- (double)addressLongitude;

@end
