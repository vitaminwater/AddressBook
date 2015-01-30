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
        self.backgroundColor = [UIColor clearColor];
        
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
    if ([_constraints count])
        [self removeConstraints:_constraints];
    _constraints = [@[] mutableCopy];
    
    if ([_widgets count] == 0)
        return;
    
    NSMutableDictionary *views = [@{} mutableCopy];
    
    NSUInteger index = 0;
    NSMutableString *format = [@"V:|" mutableCopy];
    for (UIView *view in _widgets) {
        NSString *key = [NSString stringWithFormat:@"view%d", (unsigned int)index];
        views[key] = view;
        if (index != 0)
            [format appendString:@"-"];
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

@end
