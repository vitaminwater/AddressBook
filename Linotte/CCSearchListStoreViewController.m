//
//  CCSearchListStoreViewController.m
//  Linotte
//
//  Created by stant on 04/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import "CCSearchListStoreViewController.h"

#import "CCLinotteEngineCoordinator.h"
#import "CCLinotteAuthenticationManager.h"
#import "CCLinotteAPI.h"

#import "CCBaseListStoreView.h"
#import "CCSearchListStoreView.h"

@implementation CCSearchListStoreViewController
{
    BOOL _isSearching;
    NSString *_nextSearch;
}

- (void)loadView
{
    [super loadView];
    self.title = NSLocalizedString(@"LIST_STORE_SEARCH_NAME", @"");
}

- (UIView *)setViewWithListStoreView:(CCBaseListStoreView *)listStoreView
{
    CCSearchListStoreView *view = [[CCSearchListStoreView alloc] initWithListStoreView:listStoreView];
    view.delegate = self;
    return view;
}

- (CCBaseListStoreView *)listStoreView
{
    return ((CCSearchListStoreView *)self.view).listStoreView;
}

#pragma mark - Data methods

- (void)search:(NSString *)search
{
    if (CCLEC.authenticationManager.readyToSend == NO)
        return;
    _isSearching = YES;
    [CCLEC.linotteAPI searchLists:search success:^(NSArray *lists) {
        self.lists = lists;
        _isSearching = NO;
        if (_nextSearch != nil) {
            [self search:_nextSearch];
            _nextSearch = nil;
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        _isSearching = NO;
    }];
}

#pragma mark - CCFlatListStoreViewDelegate methods

- (void)listSelectedAtIndex:(NSUInteger)index
{
    [super listSelectedAtIndex:index];
    [self.view resignFirstResponder];
}

#pragma mark - CCSearchListStoreViewDelegate methods

- (void)searchTextChanged:(NSString *)search
{
    if (_isSearching == YES) {
        _nextSearch = search;
        return;
    }
    
    [self search:search];
}

@end
