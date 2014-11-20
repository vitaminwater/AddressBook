//
//  CCUserDefaults.m
//  Linotte
//
//  Created by stant on 20/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCUserDefaults.h"

#define kCCLastUserEventDate @"kCCLastUserEventDate"

@implementation CCUserDefaults
{
    NSDateFormatter *_dateFormatter;
}

@dynamic lastUserEventDate;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dateFormatter = [NSDateFormatter new];
        [_dateFormatter setLocale:[NSLocale currentLocale]];
        [_dateFormatter setDateFormat:@"yyyy'-'MM'-'dd HH':'mm':'ss'.'SSS"];
        [_dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }
    return self;
}

- (NSDate *)lastUserEventDate
{
    NSString *lastUserEventDateString = [[NSUserDefaults standardUserDefaults] valueForKey:kCCLastUserEventDate];
    
    if (lastUserEventDateString == nil)
        return nil;
    
    return [_dateFormatter dateFromString:lastUserEventDateString];
}

- (void)setLastUserEventDate:(NSDate *)lastEventDate
{
    NSString *lastEventDateString = [_dateFormatter stringFromDate:lastEventDate];
    
    [[NSUserDefaults standardUserDefaults] setValue:lastEventDateString forKey:kCCLastUserEventDate];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Singleton method

+ (instancetype)sharedInstance
{
    static id instance = nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        instance = [self new];
    });
    
    return instance;
}

@end
