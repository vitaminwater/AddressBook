//
//  CCListOptionButton.m
//  Linotte
//
//  Created by stant on 15/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListOptionButton.h"


@implementation CCListOptionButton
{
    UIView *_topColorView;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self setupTopColorView];
    }
    return self;
}

- (void)setupTopColorView
{
    CGRect bounds = self.bounds;
    CGRect topColor = CGRectMake(0, 0, bounds.size.width, 5);
    _topColorView = [UIView new];
    _topColorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _topColorView.frame = topColor;
    [self addSubview:_topColorView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setNeedsDisplay];
    
    CGRect bounds = self.bounds;
    CGRect imageFrame = self.imageView.frame;
    CGRect titleFrame = self.titleLabel.frame;
    
    imageFrame.size.height -= titleFrame.size.height + 10;
    imageFrame.origin.x = bounds.size.width / 2 - imageFrame.size.width / 2;
    imageFrame.origin.y = bounds.size.height / 2 - imageFrame.size.height / 2 - 10;
    
    titleFrame.size.width = bounds.size.width - 20;
    titleFrame.origin.x = bounds.size.width / 2 - titleFrame.size.width / 2;
    titleFrame.origin.y = imageFrame.origin.y + imageFrame.size.height;
    
    self.imageView.frame = imageFrame;
    self.titleLabel.frame = titleFrame;
}

- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state
{
    [super setTitleColor:color forState:state];
    _topColorView.backgroundColor = color;
}

@end
