//
//  CCListInstallerCloseButton.m
//  Linotte
//
//  Created by stant on 29/10/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListInstallerCloseButton.h"

#import <CoreGraphics/CoreGraphics.h>

@implementation CCListInstallerCloseButton

- (void)drawRect:(CGRect)rect
{
    CGRect bounds = self.bounds;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor);
    CGContextSetLineWidth(context, 1);
    
    CGContextMoveToPoint(context, 1, 1);
    CGContextAddLineToPoint(context, bounds.size.width - 1, 1);
    CGContextAddLineToPoint(context, bounds.size.width - 1, bounds.size.height / 2);
    CGContextAddArcToPoint(context, bounds.size.width - 1, bounds.size.height - 1, bounds.size.width - bounds.size.height / 2 - 1, bounds.size.height - 1, bounds.size.height / 2);
    CGContextAddLineToPoint(context, bounds.size.height / 2 + 1, bounds.size.height - 1);
    CGContextAddArcToPoint(context, 1, bounds.size.height - 1, 1, bounds.size.height / 2, bounds.size.height / 2);
    CGContextAddLineToPoint(context, 1, 1);
    
    if (self.state == UIControlStateNormal)
        CGContextDrawPath(context, kCGPathStroke);
    else if (self.state == UIControlStateHighlighted)
        CGContextDrawPath(context, kCGPathFillStroke);
        
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}

@end
