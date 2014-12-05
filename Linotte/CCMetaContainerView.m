//
//  CCMetaContainerView.m
//  Linotte
//
//  Created by stant on 27/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCMetaContainerView.h"

#import "CCBaseMetaWidgetProtocol.h"
#import "CCBaseMetaWidget.h"

@implementation CCMetaContainerView
{
    NSMutableArray *_widgets;
    NSMutableArray *_constraints;
    
    BOOL _batchingAdd;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        
        _widgets = [@[] mutableCopy];
        _batchingAdd = NO;
    }
    return self;
}

- (void)beginMetaAddBatch
{
    _batchingAdd = YES;
}

- (void)addMeta:(id<CCMetaProtocol>)meta
{
    CCBaseMetaWidget *widget = [CCBaseMetaWidget widgetForMeta:meta];
    
    if (widget == nil)
        return;
    
    widget.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:widget];
    
    [_widgets addObject:widget];
    
    if (_batchingAdd == NO)
        [self setupLayout];
}

- (void)addMetas:(NSArray *)metas
{
    [self beginMetaAddBatch];
    for (id<CCMetaProtocol> meta in metas) {
        [self addMeta:meta];
    }
    [self endMetaAddBatch];
}

- (void)endMetaAddBatch
{
    _batchingAdd = NO;
    [self setupLayout];
}

- (void)updateMeta:(id<CCMetaProtocol>)meta
{
    [_widgets enumerateObjectsUsingBlock:^(CCBaseMetaWidget<CCBaseMetaWidgetProtocol> *widget, NSUInteger idx, BOOL *stop) {
        if (widget.meta == meta) {
            [widget updateContent];
            *stop = YES;
        }
    }];
    [UIView animateWithDuration:0.2 animations:^{
        [self layoutIfNeeded];
    }];
}

- (void)updateMetas:(NSArray *)metas
{
    NSMutableArray *mutableMeta = [metas mutableCopy];
    [_widgets enumerateObjectsUsingBlock:^(CCBaseMetaWidget<CCBaseMetaWidgetProtocol> *widget, NSUInteger idx, BOOL *stop) {
        if ([mutableMeta containsObject:widget.meta]) {
            [mutableMeta removeObject:widget.meta];
            [widget updateContent];
            
            *stop = [mutableMeta count] == 0;
        }
    }];
    [UIView animateWithDuration:0.2 animations:^{
        [self layoutIfNeeded];
    }];
}

- (void)setupLayout
{
    if ([_widgets count] == 0)
        return;
    
    if (_constraints != nil)
        [self removeConstraints:_constraints];
    _constraints = [@[] mutableCopy];
    
    UIView *previousWidget = nil;
    for (UIView *widget in _widgets) {
        if (previousWidget != nil) {
            NSLayoutConstraint *linkConstraint = [NSLayoutConstraint constraintWithItem:previousWidget attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:widget attribute:NSLayoutAttributeTop multiplier:1 constant:-7];
            [self addConstraint:linkConstraint];
            [_constraints addObject:linkConstraint];
        }
        
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[widget]|" options:0 metrics:nil views:@{@"widget" : widget}];
        [_constraints addObjectsFromArray:horizontalConstraints];
        
        previousWidget = widget;
    }
    
    UIView *firstWidget = [_widgets firstObject];
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:firstWidget attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:7];
    [_constraints addObject:topConstraint];
    
    UIView *lastWidget = [_widgets lastObject];
    NSLayoutConstraint *bottomWidgetConstraint = [NSLayoutConstraint constraintWithItem:lastWidget attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:-7];
    [_constraints addObject:bottomWidgetConstraint];
    
    [self addConstraints:_constraints];
}

@end
