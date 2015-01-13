//
//  CCTwitterSocialButton.m
//  Linotte
//
//  Created by stant on 06/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import "CCTwitterSocialButton.h"

@implementation CCTwitterSocialButton

- (UIImage *)socialSiteIcon
{
    return [UIImage imageNamed:@"twitter_icon"];
}

#pragma mark - CCSocialButtonProtocol methods

- (NSString *)socialAccountUrl
{
    return [NSString stringWithFormat:@"https://twitter.com/%@/", self.userName];
}

@end
