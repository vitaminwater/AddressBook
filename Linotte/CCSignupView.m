//
//  CCFacebookOverlayView.m
//  Linotte
//
//  Created by stant on 08/12/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCSignUpView.h"

#import <FacebookSDK/FacebookSDK.h>

#import "CCEmailLoginView.h"

@implementation CCSignUpView
{
    UIImageView *_linotteLogo;
    FBLoginView *_facebookButton;
    UILabel *_orLabel;
    CCEmailLoginView *_emailLoginView;
    
    BOOL _keyboardOut;
    NSMutableArray *_constraints;
    NSMutableArray *_spacerViews;
    CGFloat _keyboardHeight;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.opaque = YES;
        _keyboardOut = NO;
        
        [self setupLinotteLogo];
        [self setupFacebookButton];
        [self setupOrLabel];
        [self setupEmailLoginView];
        [self setupLayout];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupLinotteLogo
{
    _linotteLogo = [UIImageView new];
    _linotteLogo.translatesAutoresizingMaskIntoConstraints = NO;
    _linotteLogo.image = [UIImage imageNamed:@"linotte_logo"];
    _linotteLogo.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_linotteLogo];
}

- (void)setupFacebookButton
{
    _facebookButton = [[FBLoginView alloc] initWithPublishPermissions:@[@"public_profile", @"email", @"user_friends"] defaultAudience:FBSessionDefaultAudienceEveryone];
    _facebookButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_facebookButton];
}

- (void)setupOrLabel
{
    _orLabel = [UILabel new];
    _orLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _orLabel.font = [UIFont fontWithName:@"Futura-Book" size:35];
    _orLabel.text = NSLocalizedString(@"OR", @"");
    _orLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_orLabel];
}

- (void)setupEmailLoginView
{
    _emailLoginView = [CCEmailLoginView new];
    _emailLoginView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_emailLoginView];
}

- (void)setupLayout
{
    if ([_constraints count] != 0)
        [self removeConstraints:_constraints];
    
    if ([_spacerViews count] != 0) {
        for (UIView *view in _spacerViews) {
            [view removeFromSuperview];
        }
    }
    
    _spacerViews = [@[] mutableCopy];
    _constraints = [@[] mutableCopy];
    
    UIView *spacerView1 = [UIView new];
    spacerView1.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:spacerView1];
    
    UIView *spacerView2 = [UIView new];
    spacerView2.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:spacerView2];

    NSDictionary *views = nil;
    
    if (_keyboardOut) {
        UIView *spacerView3 = [UIView new];
        spacerView3.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:spacerView3];
        
        NSDictionary *metrics = @{@"emailLoginHeight" : @(_emailLoginView.frame.size.height)};
        views = NSDictionaryOfVariableBindings(spacerView1, _linotteLogo, _facebookButton, _orLabel, _emailLoginView, spacerView3, spacerView2);
        
        {
            NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==40)-[_linotteLogo]-(==40)-[_facebookButton]-(==20)-[_orLabel]-(==20)-[spacerView3(==emailLoginHeight)]-(==40)-|" options:0 metrics:metrics views:views];
            [_constraints addObjectsFromArray:verticalConstraints];
        }
        
        {
            CGRect bounds = self.bounds;
            NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:_emailLoginView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:(bounds.size.height - _keyboardHeight) / 2];
            [_constraints addObject:heightConstraint];
        }
    } else {
        views = NSDictionaryOfVariableBindings(spacerView1, _linotteLogo, _facebookButton, _orLabel, _emailLoginView, spacerView2);
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==40)-[_linotteLogo]-(==40)-[_facebookButton]-(==20)-[_orLabel]-(==20)-[_emailLoginView]-(==40)-|" options:0 metrics:nil views:views];
        [_constraints addObjectsFromArray:verticalConstraints];
    }
    
    for (UIView *view in views.allValues) {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(==30)-[view]-(==30)-|" options:0 metrics:nil views:@{@"view" : view}];
        [_constraints addObjectsFromArray:horizontalConstraints];
    }
    [self addConstraints:_constraints];
}

#pragma mark - NSNotificationCenter target methods

- (void)keyboardWillShowNotification:(NSNotification *)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameEnd = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameEndRect = [keyboardFrameEnd CGRectValue];
    
    _keyboardHeight = keyboardFrameEndRect.size.height;
    
    _keyboardOut = YES;
    [self setupLayout];
    [UIView animateWithDuration:0.2 animations:^{
        for (UIView *view in self.subviews) {
            view.alpha = view != _emailLoginView ? 0 : 1;
        }
        [self layoutIfNeeded];
    }];
}

- (void)keyboardWillHideNotification:(NSNotification *)notification
{
    _keyboardOut = NO;
    [self setupLayout];
    [UIView animateWithDuration:0.2 animations:^{
        for (UIView *view in self.subviews) {
            view.alpha = 1;
        }
        [self layoutIfNeeded];
    }];
}

#pragma mark - setter methods

- (void)setDelegate:(id<CCSignUpViewDelegate, FBLoginViewDelegate>)delegate
{
    _delegate = delegate;
    _emailLoginView.delegate = delegate;
    _facebookButton.delegate = delegate;
}

@end
