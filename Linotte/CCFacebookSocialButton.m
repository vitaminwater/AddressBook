//
//  CCFacebookSocialButton.m
//  Linotte
//
//  Created by stant on 06/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import "CCFacebookSocialButton.h"

@implementation CCFacebookSocialButton

- (UIImage *)socialSiteIcon
{
    return [UIImage imageNamed:@"facebook_icon"];
}

#pragma mark - CCSocialButtonProtocol methods

- (NSString *)socialAccountUrl
{
    return [NSString stringWithFormat:@"https://www.facebook.com/%@/", self.userName];
}

@end
