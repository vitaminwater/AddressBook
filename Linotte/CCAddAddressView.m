//
//  CCAddAddressView.m
//  Linotte
//
//  Created by stant on 01/12/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCAddAddressView.h"

#import <HexColors/HexColor.h>

#import "CCTabStyleButton.h"

#define kCCButtonViewHeight @40

@implementation CCAddAddressView
{
    UIView *_buttonView;
    NSArray *_buttons;
    
    UIView *_swapperView;
}

- (instancetype)initWithSwapperView:(UIView *)swapperView
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.opaque = YES;
        _swapperView = swapperView;
        
        [self setupButtons];
        [self setupSwapperView];
        [self setupLayout];
    }
    return self;
}

- (void)setupButtons
{
    _buttonView = [UIView new];
    _buttonView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_buttonView];
    
    UIButton *nameButton = [self createButton:NSLocalizedString(@"BY_NAME", @"") textColor:[UIColor colorWithHexString:@"#ffae64"]];
    [nameButton addTarget:self action:@selector(addressMethodButton:) forControlEvents:UIControlEventTouchUpInside];
    nameButton.tag = CCAddAddressByNameType;
    nameButton.selected = YES;
    [_buttonView addSubview:nameButton];
    
    UIButton *addressButton = [self createButton:NSLocalizedString(@"BY_ADDRESS", @"") textColor:[UIColor colorWithHexString:@"#f4607c"]];
    [addressButton addTarget:self action:@selector(addressMethodButton:) forControlEvents:UIControlEventTouchUpInside];
    addressButton.tag = CCAddAddressByAddressType;
    [_buttonView addSubview:addressButton];
    
    UIButton *locationButton = [self createButton:NSLocalizedString(@"AT_LOCATION", @"") textColor:[UIColor colorWithHexString:@"#5acfc4"]];
    [locationButton addTarget:self action:@selector(addressMethodButton:) forControlEvents:UIControlEventTouchUpInside];
    locationButton.tag = CCAddAddressAtLocationType;
    [_buttonView addSubview:locationButton];
    
    _buttons = @[nameButton, addressButton, locationButton];
    
    {
        NSDictionary *views = NSDictionaryOfVariableBindings(nameButton, addressButton, locationButton);
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[nameButton][addressButton(==nameButton)][locationButton(==addressButton)]|" options:0 metrics:nil views:views];
        [self addConstraints:horizontalConstraints];
        
        for (UIView *view in views.allValues) {
            NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
            [self addConstraints:horizontalConstraints];
        }
    }
}

- (UIButton *)createButton:(NSString *)title textColor:(UIColor *)color
{
    UIButton *button = [CCTabStyleButton new];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:color forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:15];
    return button;
}

- (void)setupSwapperView
{
    _swapperView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_swapperView];
}

- (void)setupLayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_buttonView, _swapperView);
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_buttonView(==kCCButtonViewHeight)][_swapperView]|" options:0 metrics:@{@"kCCButtonViewHeight" : kCCButtonViewHeight} views:views];
    [self addConstraints:verticalConstraints];
    
    for (UIView *view in views.allValues) {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
        [self addConstraints:horizontalConstraints];
    }
}

#pragma mark - UIButton target methods

- (void)addressMethodButton:(UIButton *)target
{
    for (UIButton *button in _buttons) {
        button.selected = button == target;
    }
    [_delegate addAddressTypeChangedTo:target.tag];
}

@end
