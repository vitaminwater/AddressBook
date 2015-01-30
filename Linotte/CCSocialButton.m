//
//  CCSocialButton.m
//  Linotte
//
//  Created by stant on 06/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import "CCSocialButton.h"

@implementation CCSocialButton

- (id)initWithUserName:(NSString *)userName
{
    self = [super init];
    if (self) {
        _userName = userName;
        
        [self setImage:[self socialSiteIcon] forState:UIControlStateNormal];
    }
    return self;
}

- (UIImage *)socialSiteIcon
{
    return nil;
}

@end
