//
//  UIView+CCShowSettingsView.m
//  Linotte
//
//  Created by stant on 19/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "UIView+CCShowSettingsView.h"

@implementation UIView (CCShowSettingsView)

- (void)showSettingsView:(UIView *)settingsView
{
    settingsView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:settingsView];
    
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:settingsView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    [self addConstraint:centerXConstraint];
    
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:settingsView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    [self addConstraint:centerYConstraint];
    
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:settingsView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:-20];
    [self addConstraint:widthConstraint];
    
    settingsView.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{
        settingsView.alpha = 1;
    }];
}

- (void)hideSettingsView:(UIView *)settingsView
{
    if (settingsView == nil)
        return;
    [UIView animateWithDuration:0.2 animations:^{
        settingsView.alpha = 0;
    } completion:^(BOOL finished) {
        [settingsView removeFromSuperview];
    }];
}

@end
