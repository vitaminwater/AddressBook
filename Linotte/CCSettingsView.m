//
//  CCBaseSettingsView.m
//  Linotte
//
//  Created by stant on 19/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCSettingsView.h"

#import <HexColors/HexColor.h>

#import "CCFlatColorButton.h"

@implementation CCSettingsView
{
    UILabel *_titleLabel;
    CCFlatColorButton *_closeButton;
    
    UIView *_contentView;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"#6b6b6b" alpha:0.85];
        self.alpha = 0.5;
        self.opaque = NO;
        self.layer.cornerRadius = 15;
        self.layer.masksToBounds = YES;
        
        [self setupTitle];
        [self setupCloseButton];
    }
    return self;
}

- (void)setupTitle
{
    _titleLabel = [UILabel new];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:25];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.text = NSLocalizedString(@"SETTINGS", @"");
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleLabel];
}

- (void)setupContentView:(UIView *)contentView
{
    _contentView = contentView;
    _contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_contentView];
}

- (void)setupCloseButton
{
    _closeButton = [CCFlatColorButton new];
    _closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_closeButton setTitle:NSLocalizedString(@"CLOSE", @"") forState:UIControlStateNormal];
    [_closeButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    _closeButton.titleLabel.font = [UIFont fontWithName:@"Futura-Book" size:19];
    [_closeButton setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.5]];
    [_closeButton setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.2] forState:UIControlStateHighlighted];
    [_closeButton addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _closeButton.opaque = NO;
    [self addSubview:_closeButton];
}

- (void)setupLayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_titleLabel, _contentView, _closeButton);
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_titleLabel(==50)]-[_contentView]-[_closeButton(==50)]|" options:0 metrics:nil views:views];
    [self addConstraints:verticalConstraints];
    
    for (UIView *view in views.allValues) {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": view}];
        [self addConstraints:horizontalConstraints];
    }
}

#pragma mark - UIButton target methods

- (void)closeButtonPressed:(UIButton *)sender
{
    [_delegate closeButtonPressed:self];
}

@end
