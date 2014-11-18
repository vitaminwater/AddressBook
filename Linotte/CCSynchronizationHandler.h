//
//  CCSynchronizationHandler.h
//  Linotte
//
//  Created by stant on 30/10/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

@class CCList;

@interface CCSynchronizationHandler : NSObject<CLLocationManagerDelegate>

@property(nonatomic, assign)BOOL syncing;

- (void)performSynchronizationsWithMaxDuration:(NSTimeInterval)maxDuration list:(CCList *)list completionBlock:(void(^)(BOOL didSync))completionBlock;

+ (instancetype)sharedInstance;

@end
