//
//  CCNotificationGenerator.h
//  Linotte
//
//  Created by stant on 14/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCGeohashMonitorDelegate.h"

@interface CCNotificationGenerator : NSObject<CCGeohashMonitorDelegate>

+ (void)printLastNotif;
+ (void)resetLastNotif;

+ (void)scheduleTestLocalNotification;

+ (instancetype)sharedInstance;

@end
