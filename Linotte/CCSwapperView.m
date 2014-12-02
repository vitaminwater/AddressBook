//
//  CCSwapperView.m
//  Linotte
//
//  Created by stant on 30/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCSwapperView.h"

@implementation CCSwapperView
{
    UIView *_currentView;
}

- (instancetype)initWithFirstView:(UIView *)view
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.opaque = YES;
        _currentView = view;
        
        [self setupView:view];
    }
    return self;
}

- (void)setupView:(UIView *)view
{
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:view];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(view);
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:views];
    [self addConstraints:horizontalConstraints];
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:views];
    [self addConstraints:verticalConstraints];
}

- (void)swapCurrentViewWithView:(UIView *)view completionBlock:(void(^)())completionBlock
{
    view.alpha = 0;
    [self setupView:view];
    [self layoutIfNeeded];
    
    [UIView animateWithDuration:0.2 animations:^{
        view.alpha = 1;
    } completion:^(BOOL finished) {
        [_currentView removeFromSuperview];
        _currentView = view;
        completionBlock();
    }];
}

@end
