//
//  CCAlertView.m
//  Linotte
//
//  Created by stant on 25/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCAlertView.h"

#import <HexColors/HexColor.h>

#import "CCFlatColorButton.h"

@implementation CCAlertView
{
    id _target;
    SEL _okAction;
    SEL _cancelAction;
    
    UILabel *_label;
    UIView *_buttonView;
}

- (instancetype)initWithText:(NSString *)text target:(id)target okAction:(SEL)okAction cancelAction:(SEL)cancelAction
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        self.layer.cornerRadius = 10;
        self.clipsToBounds = YES;
        
        _target = target;
        _okAction = okAction;
        _cancelAction = cancelAction;
        
        [self setupLabel:text];
        [self setupButtonView];
        [self setupLayout];
    }
    return self;
}

- (void)dealloc
{
    
}

- (void)setupLabel:(NSString *)text
{
    _label = [UILabel new];
    _label.translatesAutoresizingMaskIntoConstraints = NO;
    _label.font = [UIFont fontWithName:@"Futura-Book" size:20];
    _label.textColor = [UIColor whiteColor];
    _label.numberOfLines = 0;
    _label.text = text;
    [self addSubview:_label];
}

- (void)setupButtonView
{
    _buttonView = [UIView new];
    _buttonView.translatesAutoresizingMaskIntoConstraints = NO;
    _buttonView.backgroundColor = [UIColor clearColor];
    [self addSubview:_buttonView];
    
    UIButton *okButton = [self createButtonWithTitle:NSLocalizedString(@"YES", @"") normalColor:[UIColor colorWithHexString:@"#5acfc4"] highlightedColor:[UIColor colorWithHexString:@"#4abfb4"]];
    [okButton addTarget:self action:@selector(okButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonView addSubview:okButton];

    UIButton *cancelButton = [self createButtonWithTitle:NSLocalizedString(@"NO", @"") normalColor:[UIColor colorWithHexString:@"#f4607c"] highlightedColor:[UIColor colorWithHexString:@"#e4506c"]];
    [cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonView addSubview:cancelButton];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(okButton, cancelButton);
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[okButton]-[cancelButton(==okButton)]|" options:0 metrics:nil views:views];
    [self addConstraints:horizontalConstraints];
    
    for (UIView *view in views.allValues) {
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
        [self addConstraints:verticalConstraints];
    }
}

- (UIButton *)createButtonWithTitle:(NSString *)title normalColor:(UIColor *)normalColor highlightedColor:(UIColor *)highlightedColor
{
    CCFlatColorButton *button = [CCFlatColorButton new];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button setTitle:title forState:UIControlStateNormal];
    button.layer.cornerRadius = 10;
    button.clipsToBounds = YES;
    
    button.backgroundColor = normalColor;
    [button setBackgroundColor:highlightedColor forState:UIControlStateHighlighted];
    
    return button;
}

- (void)setupLayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_label, _buttonView);
    NSArray *verticalContraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_label]-[_buttonView]-|" options:0 metrics:nil views:views];
    [self addConstraints:verticalContraint];
    
    for (UIView *view in views.allValues) {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[view]-|" options:0 metrics:nil views:@{@"view" : view}];
        [self addConstraints:horizontalConstraints];
    }
}

#pragma mark - UIButton target methods

- (void)okButtonPressed:(id)sender
{
    [self callSelectorOnTarget:_okAction];
}

- (void)cancelButtonPressed:(id)sender
{
    [self callSelectorOnTarget:_cancelAction];
}

- (void)callSelectorOnTarget:(SEL)selector
{
    __weak id weakSelf = self;
    NSMethodSignature *methodSignature = [_target methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation setArgument:&weakSelf atIndex:2];
    invocation.target = _target;
    invocation.selector = selector;
    [invocation invoke];
}

#pragma mark - class methods

+ (instancetype)showAlertViewWithText:(NSString *)text target:(id)target leftAction:(SEL)okAction rightAction:(SEL)cancelAction
{
    CCAlertView *alertView = [[CCAlertView alloc] initWithText:text target:target okAction:okAction cancelAction:cancelAction];
    alertView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIView *view = [UIApplication sharedApplication].delegate.window.rootViewController.view;
    [view addSubview:alertView];
    
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:alertView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    [view addConstraint:centerXConstraint];
    
    NSLayoutConstraint *centerYContraint = [NSLayoutConstraint constraintWithItem:alertView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    [view addConstraint:centerYContraint];
    
    alertView.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{
        alertView.alpha = 1;
    }];
    
    return alertView;
}

+ (void)closeAlertView:(CCAlertView *)alertView
{
    [UIView animateWithDuration:0.2 animations:^{
        alertView.alpha = 0;
    } completion:^(BOOL finished) {
        [alertView removeFromSuperview];
    }];
}

@end
