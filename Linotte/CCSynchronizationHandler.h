//
//  CCSynchronizationHandler.h
//  Linotte
//
//  Created by stant on 30/10/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

#import "CCModelChangeMonitorDelegate.h"

@interface CCSynchronizationHandler : NSObject<CCModelChangeMonitorDelegate, CLLocationManagerDelegate>

- (void)performSynchronizationsWithMaxDuration:(NSTimeInterval)duration completionBlock:(void(^)())completionBlock;
- (void)performListSynchronization:(CCList *)list completionBlock:(void(^)())completionBlock;

+ (instancetype)sharedInstance;

@end
