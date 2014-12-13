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

@property(nonatomic, strong)NSString *addressNote;

// route
- (void)launchRoute:(CCRouteType)type;

@end
