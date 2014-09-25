//
//  CCModelChangeMonitor.h
//  Linotte
//
//  Created by stant on 23/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CCModelChangeMonitorDelegate.h"

@interface CCModelChangeMonitor : NSObject<CCModelChangeMonitorDelegate>

- (void)addDelegate:(id<CCModelChangeMonitorDelegate>) delegate;
- (void)removeDelegate:(id<CCModelChangeMonitorDelegate>)delegate;

+ (instancetype)sharedInstance;

@end
