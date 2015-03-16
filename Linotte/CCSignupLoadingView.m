//
//  CCSignupLoadingView.m
//  Linotte
//
//  Created by stant on 14/03/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import "CCSignupLoadingView.h"

@implementation CCSignupLoadingView
{
    UIImageView *_linotte;
    UILabel *_label;
    
    NSLayoutConstraint *_linotteYConstraint;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
        
        [self setupLinotte];
        [self setupLabel];
        [self setupLayout];
    }
    return self;
}

- (void)setupLinotte
{
    _linotte = [UIImageView new];
    _linotte.translatesAutoresizingMaskIntoConstraints = NO;
    _linotte.image = [UIImage imageNamed:@"logo_linotte"];
    [self addSubview:_linotte];
}

- (void)setupLabel
{
    _label = [UILabel new];
    _label.translatesAutoresizingMaskIntoConstraints = NO;
    _label.numberOfLines = 0;
    _label.font = [UIFont fontWithName:@"Montserrat-Bold" size:24];
    _label.text = [NSLocalizedString(@"SIGNUP_LOADING", @"") uppercaseString];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.textColor = [UIColor darkGrayColor];
    [self addSubview:_label];
}

- (void)setupLayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_linotte, _label);
    
    NSLayoutConstraint *labelYConstraint = [NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:30];
    [self addConstraint:labelYConstraint];
    
    _linotteYConstraint = [NSLayoutConstraint constraintWithItem:_linotte attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_label attribute:NSLayoutAttributeTop multiplier:1 constant:-40];
    [self addConstraint:_linotteYConstraint];
    
    for (UIView *view in views.allValues) {
        NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        [self addConstraint:centerXConstraint];
    }
}

- (void)didMoveToSuperview
{
    [self layoutIfNeeded];
    [UIView animateKeyframesWithDuration:0.3 delay:0 options:UIViewKeyframeAnimationOptionRepeat | UIViewKeyframeAnimationOptionAutoreverse | UIViewAnimationOptionCurveEaseOut animations:^{
        _linotteYConstraint.constant = -70;
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
            [self layoutIfNeeded];
        }];
    } completion:^(BOOL finished) {}];
}

@end
