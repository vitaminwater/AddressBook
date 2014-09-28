//
//  CCListOutputListEmptyView.m
//  Linotte
//
//  Created by stant on 25/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListOutputListEmptyView.h"

#import <HexColors/HexColor.h>

#import "CCFlatColorButton.h"


@implementation CCListOutputListEmptyView
{
    UILabel *_helpLabel;
    CCFlatColorButton *_addressListButton;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self setupHelpMessage];
        [self setupAddressListButton];
        [self setupLayout];
    }
    return self;
}

- (void)setupHelpMessage
{
    _helpLabel = [UILabel new];
    _helpLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _helpLabel.textColor = [UIColor darkGrayColor];
    _helpLabel.numberOfLines = 0;
    _helpLabel.textAlignment = NSTextAlignmentCenter;
    _helpLabel.font = [UIFont fontWithName:@"Futura-Book" size:20];
    _helpLabel.text = NSLocalizedString(@"LIST_OUTPUT_EMPTY_MESSAGE", @"");
    [self addSubview:_helpLabel];
}

- (void)setupAddressListButton
{
    _addressListButton = [CCFlatColorButton new];
    _addressListButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_addressListButton setTitle:NSLocalizedString(@"LIST_OUTPUT_EMPTY_BUTTON", @"") forState:UIControlStateNormal];
    _addressListButton.backgroundColor = [UIColor colorWithHexString:@"#ffae64"];
    [_addressListButton setBackgroundColor:[UIColor colorWithHexString:@"#ef9e54"] forState:UIControlStateHighlighted];
    _addressListButton.titleLabel.font = [UIFont fontWithName:@"Futura-Book" size:20];
    _addressListButton.layer.cornerRadius = 15;
    _addressListButton.clipsToBounds = YES;
    [_addressListButton addTarget:self action:@selector(addressListButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_addressListButton];
}

- (void)setupLayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_helpLabel, _addressListButton);
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_helpLabel]-(==8)-[_addressListButton(==50)]" options:0 metrics:nil views:views];
    [self addConstraints:verticalConstraints];
    
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:_helpLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:-4];
    [self addConstraint:centerYConstraint];
    
    for (UIView *view in views.allValues) {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[view]-|" options:0 metrics:nil views:@{@"view" : view}];
        [self addConstraints:horizontalConstraints];
    }
}

#pragma mark - UIButton target methods

- (void)addressListButtonPressed:(id)sender
{
    [_delegate showAddressList];
}

@end
