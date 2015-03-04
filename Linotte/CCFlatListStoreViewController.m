//
//  CCFlatListStoreViewController.m
//  Linotte
//
//  Created by stant on 05/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import "CCFlatListStoreViewController.h"

#import "CCLinotteEngineCoordinator.h"
#import "CCLinotteAuthenticationManager.h"

#import "CCFlatListStoreView.h"

@implementation CCFlatListStoreViewController
{
    CCFlatListStoreView *_listStoreView;
}

- (void)loadView
{
    [super loadView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _listStoreView = [CCFlatListStoreView new];
    _listStoreView.delegate = self;
    self.view = [self setViewWithListStoreView:_listStoreView];
}

- (UIView *)setViewWithListStoreView:(UIView *)listStoreView
{
    return listStoreView;
}

#pragma mark - setter methods

- (void)setLists:(NSArray *)lists
{
    _lists = lists;
    [_listStoreView reloadData];
}

#pragma mark - CCFlatListStoreViewDelegate

- (void)listSelectedAtIndex:(NSUInteger)index
{
    NSDictionary *listDict = _lists[index];
    
    [self showListInstaller:listDict[@"identifier"]];
}

- (NSUInteger)numberOfLists
{
    return [_lists count];
}

- (NSString *)nameForListAtIndex:(NSUInteger)index
{
    NSDictionary *listDict = _lists[index];
    return listDict[@"name"];
}

- (NSString *)authorForListAtIndex:(NSUInteger)index
{
    NSDictionary *listDict = _lists[index];
    return listDict[@"author"];
}

- (NSString *)iconUrlForListAtIndex:(NSUInteger)index
{
    NSDictionary *listDict = _lists[index];
    return listDict[@"icon"];
}

@end
