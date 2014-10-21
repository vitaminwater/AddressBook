//
//  CCNetworkHandler.h
//  Linotte
//
//  Created by stant on 15/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CCModelChangeMonitorDelegate.h"

@interface CCNetworkHandler : NSObject<CCModelChangeMonitorDelegate>

@property(nonatomic, assign)BOOL isLoggedIn;

- (BOOL)connectionAvailable;

- (void)resetAllAdresses;

+ (instancetype)sharedInstance;

@end
