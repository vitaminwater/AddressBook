//
//  CCDisplayMeta.m
//  Linotte
//
//  Created by stant on 27/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCDisplayMeta.h"

@implementation CCDisplayMeta
{
    UILabel *_titleLabel;
    UILabel *_textLabel;
}

- (instancetype)initWithMeta:(id<CCMetaProtocol>)meta
{
    self = [super initWithMeta:meta];
    if (self) {
        [self setupLabels];
        [self setupLayout];
    }
    return self;
}

- (void)setupLabels
{
    _titleLabel = [UILabel new];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.textColor = [UIColor darkGrayColor];
    _titleLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:18];
    _titleLabel.numberOfLines = 0;
    [self addSubview:_titleLabel];
    
    _textLabel = [UILabel new];
    _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _textLabel.textColor = [UIColor darkGrayColor];
    _textLabel.font = [UIFont fontWithName:@"Futura-Book" size:15];
    _textLabel.numberOfLines = 0;
    [self addSubview:_textLabel];
    
    [self updateContent];
}

- (void)setupLayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_titleLabel, _textLabel);
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_titleLabel]-(==4)-[_textLabel]|" options:0 metrics:nil views:views];
    [self addConstraints:verticalConstraints];
    
    for (UIView *view in views.allValues) {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
        [self addConstraints:horizontalConstraints];
    }
}

#pragma mark - CCBaseMetaWidgetProtocol methods

- (void)updateContent
{
    _titleLabel.text = self.meta.content[@"title"];
    _textLabel.text = self.meta.content[@"text"];
}

+ (NSString *)action
{
    return @"display";
}

@end
