//
//  CCNetworkLogs.h
//  Linotte
//
//  Created by stant on 18/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CCLog(fmt, ...) [CCNetworkLogs log:fmt, ##__VA_ARGS__] 

@interface CCNetworkLogs : NSObject

+ (void)log:(NSString *)format, ...;

+ (instancetype)sharedInstance;

@end
