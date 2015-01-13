//
//  CCFoursquareSocialButton.m
//  Linotte
//
//  Created by stant on 06/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import "CCFoursquareSocialButton.h"

@implementation CCFoursquareSocialButton

- (UIImage *)socialSiteIcon
{
    return [UIImage imageNamed:@"foursquare_icon"];
}

#pragma mark - CCSocialButtonProtocol methods

- (NSString *)socialAccountUrl
{
    return [NSString stringWithFormat:@"https://foursquare.com/%@/", self.userName];
}

@end
