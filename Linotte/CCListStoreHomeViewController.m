//
//  CCListStoreViewController.m
//  Linotte
//
//  Created by stant on 09/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListStoreHomeViewController.h"

#import <HexColors/HexColor.h>

#import "CCLinotteEngineCoordinator.h"
#import "CCLinotteAuthenticationManager.h"
#import "CCLinotteAPI.h"
#import "CCModelChangeHandler.h"

#import "CCSearchListStoreViewController.h"
#import "CCGroupListStoreViewController.h"

#import "CCLocationMonitor.h"

#import "CCList.h"
#import "CCListStoreHomeView.h"


@implementation CCListStoreHomeViewController
{
    NSArray *_groups;
}

- (void)loadView
{
    [super loadView];
    
    self.title = NSLocalizedString(@"LIST_STORE_SCREEN_NAME", @"");
    
    CCListStoreHomeView *view = [CCListStoreHomeView new];
    view.delegate = self;
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect searchButtonFrame = CGRectMake(0, 0, 25, 25);
    UIButton *searchButton = [UIButton new];
    [searchButton setImage:[UIImage imageNamed:@"search_icon.png"] forState:UIControlStateNormal];
    searchButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    searchButton.frame = searchButtonFrame;
    [searchButton addTarget:self action:@selector(searchButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *searchButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    
    UIBarButtonItem *emptyBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    emptyBarButtonItem.width = -10;
    self.navigationItem.rightBarButtonItems = @[emptyBarButtonItem, searchButtonItem];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([_groups count] == 0) {
        [self loadData:0];
    }
}

#pragma mark - UIButton target methods

- (void)searchButtonPressed:(id)sender
{
    CCSearchListStoreViewController *searchListStoreViewController = [CCSearchListStoreViewController new];
    [self.navigationController pushViewController:searchListStoreViewController animated:YES];
}

#pragma mark - Data methods

- (void)loadData:(NSUInteger)pageNumber
{
    if (CCLEC.authenticationManager.readyToSend == NO)
        return;
    [CCLEC.linotteAPI fetchGroupsAroundMe:self.location.coordinate success:^(NSArray *groups) {
        _groups = groups;
        [((CCBaseListStoreView *)self.view) reloadData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
    }];
}

#pragma mark - UIListStoreViewDelegate methods

- (void)groupSelectedAtIndex:(NSUInteger)groupIndex
{
    NSDictionary *groupDict = _groups[groupIndex];
    CCGroupListStoreViewController *groupListStoreViewController = [[CCGroupListStoreViewController alloc] initWithGroup:groupDict];
    [self.navigationController pushViewController:groupListStoreViewController animated:YES];
}

- (void)listSelectedAtIndex:(NSUInteger)index forGroupAtIndex:(NSUInteger)groupIndex
{
    NSDictionary *groupDict = _groups[groupIndex];
    NSDictionary *listDict = groupDict[@"lists"][index];

    [self showListInstaller:listDict];
}

- (NSUInteger)numberOfGroups
{
    return [_groups count];
}

- (NSString *)nameForGroupAtIndex:(NSUInteger)groupIndex
{
    NSDictionary *groupDict = _groups[groupIndex];
    return groupDict[@"name"];
}

- (NSUInteger)numberOfListsForGroupAtIndex:(NSUInteger)groupIndex
{
    NSDictionary *groupDict = _groups[groupIndex];
    return [groupDict[@"lists"] count];
}

- (NSString *)nameForListAtIndex:(NSUInteger)index forGroupAtIndex:(NSUInteger)groupIndex
{
    NSDictionary *groupDict = _groups[groupIndex];
    NSDictionary *listDict = groupDict[@"lists"][index];
    return listDict[@"name"];
}

- (NSString *)authorForListAtIndex:(NSUInteger)index forGroupAtIndex:(NSUInteger)groupIndex
{
    NSDictionary *groupDict = _groups[groupIndex];
    NSDictionary *listDict = groupDict[@"lists"][index];
    return listDict[@"author"];
}

- (NSString *)iconUrlForListAtIndex:(NSUInteger)index forGroupAtIndex:(NSUInteger)groupIndex
{
    NSDictionary *groupDict = _groups[groupIndex];
    NSDictionary *listDict = groupDict[@"lists"][index];
    return listDict[@"icon"];
}

@end
