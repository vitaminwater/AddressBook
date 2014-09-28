//
//  CCListListView.m
//  Linotte
//
//  Created by stant on 13/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListListView.h"

@implementation CCListListView
{
    UIView *_addListView;
    UIView *_listView;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setupAddListView:(UIView *)addListView
{
    _addListView = addListView;
    _addListView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_addListView];
}

- (void)setupListView:(UIView *)listView
{
    _listView = listView;
    _listView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_listView];
}

- (void)setupLayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_addListView, _listView);
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_addListView][_listView]|" options:0 metrics:nil views:views];
    [self addConstraints:verticalConstraints];
    
    for (UIView *view in views.allValues) {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
        [self addConstraints:horizontalConstraints];
    }
}

@end
