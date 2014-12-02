//
//  CCAddAddressButton.m
//  Linotte
//
//  Created by stant on 02/12/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCTabStyleButton.h"

@implementation CCTabStyleButton

- (void)drawRect:(CGRect)rect
{
    CGRect bounds = self.bounds;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0.8 alpha:1].CGColor);
    
    CGFloat offset = 1;
    
    if (self.selected) {
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextSetLineWidth(context, 2);
    } else {
        CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0.9 alpha:1].CGColor);
        CGContextSetLineWidth(context, 1);
        offset = 2;
    }

    CGContextMoveToPoint(context, offset, bounds.size.height);
    CGContextAddLineToPoint(context, offset, 4 + offset);
    CGContextAddArcToPoint(context, offset, offset, 4 + offset, offset, 4);
    CGContextAddLineToPoint(context, bounds.size.width - (4 + offset), offset);
    CGContextAddArcToPoint(context, bounds.size.width - offset, offset, bounds.size.width - offset, 4 + offset, 4);
    CGContextAddLineToPoint(context, bounds.size.width - offset, bounds.size.height);
    
    CGContextDrawPath(context, kCGPathFillStroke);
    
    if (self.isSelected == NO) {
        CGContextMoveToPoint(context, 0, bounds.size.height - 1);
        CGContextAddLineToPoint(context, bounds.size.width, bounds.size.height - 1);
        CGContextDrawPath(context, kCGPathStroke);
    }
    
    [super drawRect:rect];
}

@end
