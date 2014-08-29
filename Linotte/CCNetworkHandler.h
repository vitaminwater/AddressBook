//
//  CCNetworkHandler.h
//  Linotte
//
//  Created by stant on 15/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCAddress;

@interface CCNetworkHandler : NSObject

@property(nonatomic, assign)BOOL isLoggedIn;

- (BOOL)connectionAvailable;

- (void)sendAddress:(CCAddress *)address;

- (void)resetAllAdresses;

+ (instancetype)sharedInstance;

@end
