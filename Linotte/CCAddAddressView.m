//
//  CCAddAddressView.m
//  Linotte
//
//  Created by stant on 01/12/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCAddAddressView.h"

@implementation CCAddAddressView
{
    UINavigationBar *_navigationBar;
    
    UIView *_swapperView;
}

- (instancetype)initWithSwapperView:(UIView *)swapperView
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.opaque = YES;
        _swapperView = swapperView;

        [self setupSwapperView];
        [self setupLayout];
    }
    return self;
}

- (void)setupSwapperView
{
    _swapperView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_swapperView];
}

- (void)setupLayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_swapperView);
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_swapperView]|" options:0 metrics:nil views:views];
    [self addConstraints:verticalConstraints];
    
    for (UIView *view in views.allValues) {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
        [self addConstraints:horizontalConstraints];
    }
}

@end
