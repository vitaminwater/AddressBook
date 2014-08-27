//
//  CCOAuthTokenResponse.m
//  AdRem
//
//  Created by stant on 16/04/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCOAuthTokenResponse.h"

@implementation CCOAuthTokenResponse

- (NSString *)expireTimeStampString
{
    NSUInteger expireTimeStamp = [[NSDate date] timeIntervalSince1970] + [_expiresIn integerValue];
    return [NSString stringWithFormat:@"%d", expireTimeStamp];
}

@end
