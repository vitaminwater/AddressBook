//
//  CCUserDefaults.h
//  Linotte
//
//  Created by stant on 20/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CCUD [CCUserDefaults sharedInstance]

@interface CCUserDefaults : NSObject

@property(nonatomic, strong)NSDate *lastUserEventDate;

+ (instancetype)sharedInstance;

@end
