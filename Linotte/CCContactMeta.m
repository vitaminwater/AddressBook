//
//  CCTelMeta.m
//  Linotte
//
//  Created by stant on 27/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCContactMeta.h"

#import "CCContactButtonProtocol.h"

#import "CCTelephoneButton.h"
#import "CCWeblinkButton.h"
#import "CCEmailButton.h"

@implementation CCContactMeta
{
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
    [self setupButtons];
    [self setupLayout];
}

- (void)setupButtons
{
    _contactButtons = [@[] mutableCopy];
    
    if (self.meta.content[@"tel"] != nil) {
        [self addContactButton:[[CCTelephoneButton alloc] initWithNumber:self.meta.content[@"tel"]]];
    }
    if (self.meta.content[@"email"] != nil) {
        [self addContactButton:[[CCEmailButton alloc] initWithEmail:self.meta.content[@"email"]]];
    }
    if (self.meta.content[@"weblink"] != nil) {
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
    
    NSMutableDictionary *views = [@{} mutableCopy];
    
    NSUInteger index = 0;
    NSMutableString *format = [@"V:|" mutableCopy];
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
    return @"contact";
}

@end
