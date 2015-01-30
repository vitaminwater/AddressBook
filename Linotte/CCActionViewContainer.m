//
//  CCActionViewContainer.m
//  Linotte
//
//  Created by stant on 29/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import "CCActionViewContainer.h"

@implementation CCActionViewContainer
{
    UIView *_currentActionView;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        self.layer.cornerRadius = 5;
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)setupActionView:(UIView *)actionView
{
    if (_currentActionView != nil) {
        [_currentActionView removeFromSuperview];
    }
    
    _currentActionView = actionView;
    actionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:actionView];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(actionView);
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[actionView]-|" options:0 metrics:nil views:views];
    [self addConstraints:horizontalConstraints];
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[actionView]-|" options:0 metrics:nil views:views];
    [self addConstraints:verticalConstraints];
}

@end
