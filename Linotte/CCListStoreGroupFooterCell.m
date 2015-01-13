//
//  CCListStoreGroupFooterCell.m
//  Linotte
//
//  Created by stant on 05/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import "CCListStoreGroupFooterCell.h"

#import <HexColors/HexColor.h>

@implementation CCListStoreGroupFooterCell
{
    UIButton *_button;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupButton];
        [self setupLayout];
    }
    return self;
}

- (void)setupButton
{
    _button = [UIButton new];
    _button.translatesAutoresizingMaskIntoConstraints = NO;
    _button.titleLabel.font = [UIFont fontWithName:@"Futura-BookItalic" size:25];
    [_button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_button setTitle:NSLocalizedString(@"LIST_STORE_SEE_MORE", @"") forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_button];
}

- (void)setupLayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_button);
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[_button]-|" options:0 metrics:nil views:views];
    [self.contentView addConstraints:horizontalConstraints];
    
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:_button attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    [self.contentView addConstraint:centerYConstraint];
}

#pragma mark - UIButton target methods

- (void)buttonPressed:(id)sender
{
    [_delegate groupCellPressed:self];
}

@end
