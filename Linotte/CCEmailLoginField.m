//
//  CCEmailLoginField.m
//  Linotte
//
//  Created by stant on 12/12/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCEmailLoginField.h"

@implementation CCEmailLoginField

- (CGRect)textRectForBounds:(CGRect)bounds
{
    CGRect rect = [super textRectForBounds:bounds];
    rect.origin.x += 10;
    rect.size.width -= 20;
    return rect;
}

@end
