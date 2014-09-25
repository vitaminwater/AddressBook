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

@interface CCListOutputListEmptyView()

@property(nonatomic, strong)UILabel *helpMessage;
@property(nonatomic, strong)CCFlatColorButton *addressListButton;

@end

@implementation CCListOutputListEmptyView

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
    _helpMessage = [UILabel new];
    _helpMessage.translatesAutoresizingMaskIntoConstraints = NO;
    _helpMessage.text = NSLocalizedString(@"LIST_OUTPUT_EMPTY_MESSAGE", @"");
    [self addSubview:_helpMessage];
}

- (void)setupAddressListButton
{
    _addressListButton = [CCFlatColorButton new];
    _addressListButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_addressListButton setTitle:NSLocalizedString(@"LIST_OUTPUT_EMPTY_BUTTON", @"") forState:UIControlStateNormal];
    _addressListButton.backgroundColor = [UIColor colorWithHexString:@"#ffae64"];
    [_addressListButton setBackgroundColor:[UIColor colorWithHexString:@"#ef9e54"] forState:UIControlStateHighlighted];
    _addressListButton.layer.cornerRadius = 10;
    _addressListButton.clipsToBounds = YES;
    [_addressListButton addTarget:self action:@selector(addressListButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_addressListButton];
}

- (void)setupLayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_helpMessage, _addressListButton);
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_helpMessage]-(==8)-[_addressListButton]" options:0 metrics:nil views:views];
    [self addConstraints:verticalConstraints];
    
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:_helpMessage attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:-4];
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
