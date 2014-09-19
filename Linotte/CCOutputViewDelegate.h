//
//  CCOutputViewDelegate.h
//  Linotte
//
//  Created by stant on 12/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    CCRouteTypeTrain,
    CCRouteTypeCar,
    CCRouteTypeBicycling,
    CCRouteTypeWalk
} CCRouteType;

@protocol CCOutputViewDelegate <NSObject>

// route
- (void)launchRoute:(CCRouteType)type;

// address display
- (double)addressDistance;
- (NSString *)addressName;
- (NSString *)addressString;
- (NSString *)addressProvider;
- (double)addressLatitude;
- (double)addressLongitude;

@end
