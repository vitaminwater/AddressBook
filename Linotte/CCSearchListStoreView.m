//
//  CCSearchListStoreView.m
//  Linotte
//
//  Created by stant on 05/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import "CCSearchListStoreView.h"

#import "CCBaseListStoreView.h"

#import "CCLinotteField.h"

@implementation CCSearchListStoreView
{
    CCBaseListStoreView *_listStoreView;
    CCLinotteField *_searchField;
}

@synthesize listStoreView = _listStoreView;

- (instancetype)initWithListStoreView:(CCBaseListStoreView *)listStoreView
{
    self = [super init];
    if (self) {
        [self setupSearchField];
        [self setupListStoreView:listStoreView];
        [self setupLayout];
    }
    return self;
}

- (void)setupSearchField
{
    _searchField = [[CCLinotteField alloc] initWithImage:[UIImage imageNamed:@"search_icon"]];
    _searchField.translatesAutoresizingMaskIntoConstraints = NO;
    _searchField.placeholder = NSLocalizedString(@"SEARCH", @"");
    [_searchField addTarget:self action:@selector(searchFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    _searchField.delegate = self;
    [self addSubview:_searchField];
}

- (void)setupListStoreView:(CCBaseListStoreView *)listStoreView
{
    _listStoreView = listStoreView;
    _listStoreView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_listStoreView];
}

- (void)setupLayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_searchField, _listStoreView);
    NSDictionary *metrics = @{@"kCCLinotteTextFieldHeight" : kCCLinotteTextFieldHeight};
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_searchField(==kCCLinotteTextFieldHeight)][_listStoreView]|" options:0 metrics:metrics views:views];
    [self addConstraints:verticalConstraints];
    
    for (UIView *view in views.allValues) {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
        [self addConstraints:horizontalConstraints];
    }
}

- (BOOL)resignFirstResponder
{
    [_searchField resignFirstResponder];
    return [super resignFirstResponder];
}

#pragma mark - UITextField target methods

- (void)searchFieldChanged:(UITextField *)sender
{
    [_delegate searchTextChanged:sender.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_searchField resignFirstResponder];
    return NO;
}

@end
