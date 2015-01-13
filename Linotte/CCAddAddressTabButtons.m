//
//  CCAddAddressTabButtons.m
//  Linotte
//
//  Created by stant on 06/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import "CCAddAddressTabButtons.h"

#import <HexColors/HexColor.h>

#import "CCTabStyleButton.h"

@implementation CCAddAddressTabButtons
{
    NSArray *_buttons;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupButtons];
    }
    return self;
}

- (void)setupButtons
{
    UIButton *nameButton = [self createButton:NSLocalizedString(@"BY_NAME", @"") textColor:[UIColor colorWithHexString:@"#ffae64"]];
    [nameButton addTarget:self action:@selector(addressMethodButton:) forControlEvents:UIControlEventTouchUpInside];
    nameButton.tag = CCAddAddressByNameType;
    nameButton.selected = YES;
    [self addSubview:nameButton];
    
    UIButton *addressButton = [self createButton:NSLocalizedString(@"BY_ADDRESS", @"") textColor:[UIColor colorWithHexString:@"#f4607c"]];
    [addressButton addTarget:self action:@selector(addressMethodButton:) forControlEvents:UIControlEventTouchUpInside];
    addressButton.tag = CCAddAddressByAddressType;
    [self addSubview:addressButton];
    
    UIButton *locationButton = [self createButton:NSLocalizedString(@"AT_LOCATION", @"") textColor:[UIColor colorWithHexString:@"#5acfc4"]];
    [locationButton addTarget:self action:@selector(addressMethodButton:) forControlEvents:UIControlEventTouchUpInside];
    locationButton.tag = CCAddAddressAtLocationType;
    [self addSubview:locationButton];
    
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

- (void)setSelectedTabButton:(CCAddAddressType)type
{
    for (UIButton *button in _buttons) {
        button.selected = button.tag == type;
    }
}

#pragma mark - UIButton target methods

- (void)addressMethodButton:(UIButton *)target
{
    [self setSelectedTabButton:target.tag];
    [_delegate addAddressTypeChangedTo:target.tag];
}

@end
