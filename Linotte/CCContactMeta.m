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

@implementation CCContactMeta
{
    NSMutableArray *_contactButtons;
    NSMutableArray *_constraints;
}

- (instancetype)initWithMeta:(id<CCMetaProtocol>)meta
{
    self = [super initWithMeta:meta];
    if (self) {
        [self setupContactButtons];
        [self setupLayout];
    }
    return self;
}

- (void)setupContactButtons
{
    _contactButtons = [@[] mutableCopy];
    
    if (self.meta.content[@"tel"] != nil) {
        CCTelephoneButton *telButton = [[CCTelephoneButton alloc] initWithNumber:self.meta.content[@"tel"]];
        telButton.translatesAutoresizingMaskIntoConstraints = NO;
        [telButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:telButton];
        [_contactButtons addObject:telButton];
    }
}

- (void)setupLayout
{
    if (_constraints != nil)
        [self removeConstraints:_constraints];
    _constraints = [@[] mutableCopy];
    
    UIButton *previousButton = nil;
    for (UIButton *contactButton in _contactButtons) {
        if (previousButton != nil) {
            NSLayoutConstraint *linkConstraint = [NSLayoutConstraint constraintWithItem:previousButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:contactButton attribute:NSLayoutAttributeTop multiplier:1 constant:7];
            [self addConstraint:linkConstraint];
            [_constraints addObject:linkConstraint];
        }
        
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contactButton]|" options:0 metrics:nil views:@{@"contactButton" : contactButton}];
        [_constraints addObjectsFromArray:horizontalConstraints];
        
        previousButton = contactButton;
    }
    
    UIView *firstButton = [_contactButtons firstObject];
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:firstButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:7];
    [_constraints addObject:topConstraint];
    
    UIView *lastButton = [_contactButtons lastObject];
    NSLayoutConstraint *bottomWidgetConstraint = [NSLayoutConstraint constraintWithItem:lastButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:-7];
    [_constraints addObject:bottomWidgetConstraint];
    
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
    
}

+ (NSString *)action
{
    return @"contact";
}

@end
