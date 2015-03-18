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
@property(nonatomic, strong)NSDate *lastUserEventUpdate;
@property(nonatomic, strong)NSData *pushNotificationDeviceToken;
@property(nonatomic, assign)BOOL pushNotificationDeviceTokenSent;

- (void)totallyKillCurrentSession;

+ (instancetype)sharedInstance;

@end
