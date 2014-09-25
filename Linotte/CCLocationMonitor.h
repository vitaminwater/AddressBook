//
//  CCLocationMonitor.h
//  Linotte
//
//  Created by stant on 25/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

@interface CCLocationMonitor : NSObject<CLLocationManagerDelegate>

- (void)addDelegate:(id<CLLocationManagerDelegate>)delegate;
- (void)removeDelegate:(id<CLLocationManagerDelegate>)delegate;

+ (instancetype)sharedInstance;

@end
