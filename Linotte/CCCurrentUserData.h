//
//  CCUserDefaults.h
//  Linotte
//
//  Created by stant on 20/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CCUD [CCCurrentUserData sharedInstance]

@interface CCCurrentUserData : NSObject

@property(nonatomic, strong)NSDate *lastUserEventDate;

+ (instancetype)sharedInstance;

@end
