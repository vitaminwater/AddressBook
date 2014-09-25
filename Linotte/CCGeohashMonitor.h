//
//  CCNotificationGenerator.h
//  AdRem
//
//  Created by stant on 09/02/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

#import "CCGeohashMonitorDelegate.h"

@interface CCGeohashMonitor : NSObject<CLLocationManagerDelegate>

@property(nonatomic, weak)id<CCGeohashMonitorDelegate> delegate;

+ (instancetype)sharedInstance;

@end
