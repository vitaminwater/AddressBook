//
//  CCMainView.m
//  Linotte
//
//  Created by stant on 07/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCMainView.h"

#import "CCAddViewConstants.h"

@interface CCMainView()
{
    UIView *_addView;
    UIView *_listView;
    
    NSArray *_addViewVerticalConstraints;
    NSArray *_listViewVerticalConstraints;
}

@end

@implementation CCMainView

- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"linotte_bg.png"]];
    }
    return self;
}

- (void)setupAddView:(UIView *)addView
{
    _addView = addView;
    
    _addView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_addView];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_addView);
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_addView]|" options:0 metrics:nil views:views];
    [self addConstraints:horizontalConstraints];
    
    [self setupAddViewVerticalConstraints];
}

- (void)setupListView:(UIView *)listView
{
    NSAssert(_addView != nil, kCCWrongSetupMethodsOrderError);
    
    _listView = listView;
    
    _listView.translatesAutoresizingMaskIntoConstraints = NO;
    [self insertSubview:_listView belowSubview:_addView];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_addView, _listView);
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_listView]|" options:0 metrics:nil views:views];
    [self addConstraints:horizontalConstraints];
    
    [self setupListViewVerticalConstraints];
}

- (void)setupAddViewVerticalConstraints
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_addView);
    
    if (_addViewVerticalConstraints)
        [self removeConstraints:_addViewVerticalConstraints];
    if (_addViewExpanded) {
        _addViewVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_addView]-(==216)-|" options:0 metrics:nil views:views];
    } else {
        _addViewVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_addView(kCCAddViewTextFieldHeight)]" options:0 metrics:kCCAddViewTextFieldHeightMetric views:views];
    }
    [self addConstraints:_addViewVerticalConstraints];
}

- (void)setupListViewVerticalConstraints
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_addView, _listView);
    
    if (_listViewVerticalConstraints)
        [self removeConstraints:_listViewVerticalConstraints];
    if (_addViewExpanded) {
        _listViewVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(kCCAddViewTextFieldHeight)-[_listView]" options:0 metrics:kCCAddViewTextFieldHeightMetric views:views];
    } else {
        _listViewVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_addView][_listView]|" options:0 metrics:nil views:views];
    }
    [self addConstraints:_listViewVerticalConstraints];
}

#pragma mark - setter methods

- (void)setAddViewExpanded:(BOOL)addViewExpanded
{
    if (_addViewExpanded == addViewExpanded)
        return;
    
    [self willChangeValueForKey:@"addViewExpanded"];
    _addViewExpanded = addViewExpanded;
    [self setupAddViewVerticalConstraints];
    [self setupListViewVerticalConstraints];
    
    [UIView animateWithDuration:0.4 animations:^{
        [self layoutIfNeeded];
    }];
    
    [self didChangeValueForKey:@"addViewExpanded"];
}

@end
