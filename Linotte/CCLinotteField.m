//
//  CCLinotteField.m
//  Linotte
//
//  Created by stant on 01/12/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCLinotteField.h"

@implementation CCLinotteField

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.opaque = YES;
        self.borderStyle = UITextBorderStyleNone;
        
        [self setupSelfWithImage:image];
    }
    return self;
}

- (void)setupSelfWithImage:(UIImage *)image
{
    self.font = [UIFont fontWithName:@"Montserrat-Bold" size:20];
    self.textColor = [UIColor darkGrayColor];
    self.backgroundColor = [UIColor whiteColor];
    
    UIImageView *leftView = [UIImageView new];
    leftView.frame = CGRectMake(0, 0, 58, [kCCLinotteTextFieldHeight floatValue]);
    leftView.contentMode = UIViewContentModeCenter;
    leftView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    leftView.image = image;
    self.leftView = leftView;
    self.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *rightView = [UIView new];
    rightView.frame = CGRectMake(0, 0, 15, [kCCLinotteTextFieldHeight floatValue]);
    rightView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.rightView = rightView;
    self.rightViewMode = UITextFieldViewModeAlways;
}

- (void)drawRect:(CGRect)rect
{
    CGRect frame = self.bounds;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0.7 alpha:1].CGColor);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, frame.size.height);
    CGContextAddLineToPoint(context, frame.size.width, frame.size.height);
    CGContextStrokePath(context);
    
    [super drawRect:rect];
}

@end
