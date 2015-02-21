//
//  CCTelMeta.m
//  Linotte
//
//  Created by stant on 27/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCExternalMeta.h"

#import "CCContactButtonProtocol.h"

#import "CCTelephoneButton.h"
#import "CCWeblinkButton.h"
#import "CCEmailButton.h"

@implementation CCExternalMeta
{
    UILabel *_titleLabel;
    
    NSMutableArray *_contactButtons;
    NSMutableArray *_constraints;
}

- (instancetype)initWithMeta:(id<CCMetaProtocol>)meta
{
    self = [super initWithMeta:meta];
    if (self) {
        [self setupContent];
    }
    return self;
}

- (void)setupContent
{
    if (self.meta.content[@"title"] != nil)
        [self setupTitleLabel];
    [self setupButtons];
    [self setupLayout];
}

- (void)setupTitleLabel
{
    _titleLabel = [UILabel new];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.text = self.meta.content[@"title"];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:20];
    [self addSubview:_titleLabel];
}

- (void)setupButtons
{
    _contactButtons = [@[] mutableCopy];
    
    if (self.meta.content[@"tel"] != nil && [self.meta.content[@"tel"] length] != 0) {
        [self addContactButton:[[CCTelephoneButton alloc] initWithNumber:self.meta.content[@"tel"]]];
    }
    if (self.meta.content[@"email"] != nil && [self.meta.content[@"email"] length] != 0) {
        [self addContactButton:[[CCEmailButton alloc] initWithEmail:self.meta.content[@"email"]]];
    }
    if (self.meta.content[@"weblink"] != nil && [self.meta.content[@"weblink"] length] != 0) {
        [self addContactButton:[[CCWeblinkButton alloc] initWithLink:self.meta.content[@"weblink"]]];
    }
}

- (void)addContactButton:(UIButton *)button
{
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    [_contactButtons addObject:button];
}

- (void)setupLayout
{
    if (_constraints != nil)
        [self removeConstraints:_constraints];
    _constraints = [@[] mutableCopy];
    
    if ([_contactButtons count] == 0)
        return;
    
    if (_titleLabel != nil) {
        NSDictionary *views = NSDictionaryOfVariableBindings(_titleLabel);
        
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_titleLabel]|" options:0 metrics:nil views:views];
        [self addConstraints:horizontalConstraints];
        
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_titleLabel]" options:0 metrics:nil views:views];
        [self addConstraints:verticalConstraints];
    }
    
    {
        NSMutableDictionary *views = [@{} mutableCopy];
        
        NSUInteger index = 0;
        NSMutableString *format;
        if (_titleLabel != nil) {
            format = [@"V:|[_titleLabel]" mutableCopy];
            views[@"_titleLabel"] = _titleLabel;
        } else
            format = [@"V:|" mutableCopy];
        
        for (UIView *view in _contactButtons) {
            NSString *key = [NSString stringWithFormat:@"view%d", (unsigned int)index];
            [views setValue:view forKey:key];
            [format appendFormat:@"[%@]", key];
            ++index;
            
            NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
            [_constraints addObjectsFromArray:horizontalConstraints];
        }
        [format appendString:@"|"];
        
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:0 views:views];
        [_constraints addObjectsFromArray:verticalConstraints];
    }
    [self addConstraints:_constraints];
}

#pragma mark - UIButton target methods

- (void)buttonPressed:(UIButton<CCContactButtonProtocol> *)sender
{
    [sender buttonPressed];
}

#pragma mark - CCBaseMetaWidgetProtocol methods

- (void)updateContent
{
    for (UIView *view in _contactButtons) {
        [view removeFromSuperview];
    }
    [_contactButtons removeAllObjects];
    
    [self setupContent];
}

+ (NSString *)action
{
    return @"external";
}

@end
