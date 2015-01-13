//
//  CCPinterestSocialButton.m
//  Linotte
//
//  Created by stant on 06/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import "CCPinterestSocialButton.h"

@implementation CCPinterestSocialButton

- (UIImage *)socialSiteIcon
{
    return [UIImage imageNamed:@"pinterest_icon"];
}

#pragma mark - CCSocialButtonProtocol methods

- (NSString *)socialAccountUrl
{
    return [NSString stringWithFormat:@"https://pinterest.com/%@/", self.userName];
}

@end
