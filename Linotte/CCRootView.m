//
//  CCRootView.m
//  Linotte
//
//  Created by stant on 01/12/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCRootView.h"

#import <HexColors/HexColor.h>

#import "CCFlatColorButton.h"

@implementation CCRootView
{
    UIView *_statusBar;
    UIView *_swiperView;
    
    UITabBar *_tabBar;
    NSLayoutConstraint *_tabBarHeightConstraint;
    
    CCFlatColorButton *_keyboardButton;
    NSLayoutConstraint *_keyboardButtonHeightConstraint;

    NSLayoutConstraint *_bottomViewConstraint;
}

- (instancetype)initWithSwiperView:(UIView *)swiperView
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.opaque = YES;
        _swiperView = swiperView;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShowNotification:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHideNotification:) name:UIKeyboardWillHideNotification object:nil];
        
        [self setupStatusBar];
        [self setupSwiperView];
        [self setupKeyboardlButton];
        [self setupTabBar];
        [self setupLayout];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupKeyboardlButton
{
    _keyboardButton = [CCFlatColorButton new];
    _keyboardButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_keyboardButton setTitle:NSLocalizedString(@"HIDE_KEYBOARD", @"") forState:UIControlStateNormal];
    _keyboardButton.clipsToBounds = YES;
    
    [_keyboardButton addTarget:self action:@selector(keyboardButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _keyboardButton.backgroundColor = [UIColor colorWithHexString:@"#f4607c"];
    [_keyboardButton setBackgroundColor:[UIColor colorWithHexString:@"#e4506c"] forState:UIControlStateHighlighted];
    [self addSubview:_keyboardButton];
}

- (void)setupStatusBar
{
    _statusBar = [UIView new];
    _statusBar.translatesAutoresizingMaskIntoConstraints = NO;
    _statusBar.backgroundColor = [UIColor colorWithHexString:@"#6b6b6b"];
    _statusBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:_statusBar];
}

- (void)setupSwiperView
{
    _swiperView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_swiperView];
}

- (void)setupTabBar
{
    _tabBar = [UITabBar new];
    _tabBar.translatesAutoresizingMaskIntoConstraints = NO;
    [_tabBar setTintColor:[UIColor colorWithHexString:@"#5acfc4"]];
    [self addSubview:_tabBar];
    
    UITabBarItem *discoverItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"LIST_STORE_SCREEN_NAME", @"") image:[UIImage imageNamed:@"discover"] tag:0];
    UITabBarItem *linotteItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"HOME_SCREEN_NAME", @"") image:[UIImage imageNamed:@"add_field_icon"] tag:1];
    UITabBarItem *addAddressItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"ADD_ADDRESS_SCREEN_NAME", @"") image:[UIImage imageNamed:@"add_icon"] tag:2];
    
    _tabBar.items = @[discoverItem, linotteItem, addAddressItem];
    _tabBar.selectedItem = linotteItem;
    
    _tabBar.delegate = self;
}

- (void)setupLayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_statusBar, _swiperView, _keyboardButton, _tabBar);
    CGRect statusBarBounds = [UIApplication sharedApplication].statusBarFrame;
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_statusBar(==kCCStatusBarHeight)][_swiperView][_keyboardButton][_tabBar]" options:0 metrics:@{@"kCCStatusBarHeight" : @(statusBarBounds.size.height)} views:views];
    [self addConstraints:verticalConstraints];
    
    _bottomViewConstraint = [NSLayoutConstraint constraintWithItem:_tabBar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [self addConstraint:_bottomViewConstraint];
    
    _keyboardButtonHeightConstraint = [NSLayoutConstraint constraintWithItem:_keyboardButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:0];
    [self addConstraint:_keyboardButtonHeightConstraint];
    
    _tabBarHeightConstraint = [NSLayoutConstraint constraintWithItem:_tabBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:0];
    
    for (UIView *view in views.allValues) {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
        [self addConstraints:horizontalConstraints];
    }
}

- (void)setSelectedTabItem:(NSUInteger)index
{
    _tabBar.selectedItem = _tabBar.items[index];
}

#pragma mark - UIButton target methods

- (void)keyboardButtonPressed:(UIButton *)sender
{
    [self endEditing:YES];
}

#pragma mark - NSNotification target methods

- (void)keyboardHideNotification:(NSNotification *)notification
{
    _bottomViewConstraint.constant = 0;
    [self addConstraint:_keyboardButtonHeightConstraint];
    
    [self removeConstraint:_tabBarHeightConstraint];
    
    _tabBar.hidden = NO;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        _tabBar.alpha = 1;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {}];
}

- (void)keyboardShowNotification:(NSNotification *)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameEnd = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameEndRect = [keyboardFrameEnd CGRectValue];
    _bottomViewConstraint.constant = -keyboardFrameEndRect.size.height;
    [self removeConstraint:_keyboardButtonHeightConstraint];
    
    [self addConstraint:_tabBarHeightConstraint];
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        _tabBar.alpha = 0;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        _tabBar.hidden = YES;
    }];
}

#pragma mark - UITabBarDelegate methods

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSArray *colors = kCCLinotteColors;
    NSString *randColor = colors[rand() % [colors count]];
    NSUInteger index = item.tag;
    [_tabBar setTintColor:[UIColor colorWithHexString:randColor]];
    [_delegate tabBarItemSelectedAtIndex:index];
}

@end
