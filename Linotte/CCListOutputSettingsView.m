//
//  CCListOutputExpandedSettingsView.m
//  Linotte
//
//  Created by stant on 28/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListOutputSettingsView.h"

#import "CCListOutputListEmptyView.h"

@implementation CCListOutputSettingsView
{
    CCListOutputListEmptyView *_emptyView;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupEmptyView];
        [self setupLayout];
    }
    return self;
}

- (void)setupEmptyView
{
    _emptyView = [CCListOutputListEmptyView new];
    _emptyView.translatesAutoresizingMaskIntoConstraints = NO;
    [_emptyView setTextColor:[UIColor whiteColor]];
    _emptyView.delegate = self;
    [self addSubview:_emptyView];
}

- (void)setupLayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_emptyView);
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_emptyView]|" options:0 metrics:nil views:views];
    [self addConstraints:horizontalConstraints];

    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_emptyView]-|" options:0 metrics:nil views:views];
    [self addConstraints:verticalConstraints];
}

#pragma mark - CCListOutputListEmptyViewDelegate

- (void)showAddressList
{
    [_delegate showAddressList];
}

@end
