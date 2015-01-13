//
//  CCListViewController.m
//  Linotte
//
//  Created by stant on 06/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListViewController.h"

#import "CCLinotteCoreDataStack.h"

#import <objc/runtime.h>

#import "CCModelChangeMonitor.h"
#import "CCLocationMonitor.h"

#import "CCListViewModel.h"
#import "CCListViewContentProvider.h"

#import "CCGeohashHelper.h"

#import "NSString+CCLocalizedString.h"

#import "CCOutputViewController.h"
#import "CCListOutputViewController.h"

#import "CCListView.h"
#import "CCAnimationDelegator.h"

#import "CCAddress.h"
#import "CCList.h"

/*
 * Actual View controller implementation
 */

@implementation CCListViewController
{
    CLLocation *_currentLocation;
    CLHeading *_currentHeading;
}

- (instancetype)initWithProvider:(CCListViewContentProvider *)provider
{
    self = [super init];
    if (self) {
        _provider = provider;
        _provider.delegate = self;
        _deletableItems = YES;
    }
    return self;
}

- (void)dealloc
{
    [[CCLocationMonitor sharedInstance] removeDelegate:self];
}

- (void)loadView
{
    CCListView *listView = [[CCListView alloc] initWithAnimationDelegator:_animatorDelegator];
    listView.delegate = self;
    self.view = listView;
    
    if ([_provider numberOfListItems] == 0)
        [listView setupEmptyView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[CCLocationMonitor sharedInstance] addDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    CCListView *listView = (CCListView *)self.view;
    [listView unselect];
    
    [[CCLocationMonitor sharedInstance] addDelegate:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[CCLocationMonitor sharedInstance] removeDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    
    _provider.currentLocation = location;
    [((CCListView *)self.view) reloadVisibleCells];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)heading
{
    _provider.currentHeading = heading;
    [((CCListView *)self.view) reloadVisibleCells];
}

#pragma mark - public methods

#pragma mark - CCListViewDelegate methods

- (UIView *)getEmptyView
{
    return [_delegate getEmptyView];
}

- (void)didSelectListItemAtIndex:(NSUInteger)index
{
    CCListItemType type = [_provider listItemTypeAtIndex:index];
    if (type == CCListItemTypeAddress) {
        CCAddress *address = ((CCAddress *)[_provider listItemContentAtIndex:index]);
        [_delegate addressSelected:address];
    } else if (type == CCListItemTypeList) {
        CCList *list = (CCList *)[_provider listItemContentAtIndex:index];
        [_delegate listSelected:list];
    }
}

- (void)deleteListItemAtIndex:(NSUInteger)index
{
    CCListItemType type = [_provider listItemTypeAtIndex:index];
    if (type == CCListItemTypeAddress) {
        CCAddress *address = ((CCAddress *)[_provider listItemContentAtIndex:index]);
        [_delegate deleteAddress:address];
    } else if (type == CCListItemTypeList) {
        CCList *list = (CCList *)[_provider listItemContentAtIndex:index];
        [_delegate deleteList:list];
    }
}

- (void)setNotificationEnabled:(BOOL)enabled atIndex:(NSUInteger)index
{
    CCListItemType type = [_provider listItemTypeAtIndex:index];
    if (type == CCListItemTypeAddress) {
        CCAddress *address = ((CCAddress *)[_provider listItemContentAtIndex:index]);
        [[CCModelChangeMonitor sharedInstance] addressesWillUpdateUserData:@[address] send:YES];
        address.notify = @(enabled);
        [[CCLinotteCoreDataStack sharedInstance] saveContext];
        [[CCModelChangeMonitor sharedInstance] addressesDidUpdateUserData:@[address] send:YES];
    } else if (type == CCListItemTypeList) {
        CCList *list = (CCList *)[_provider listItemContentAtIndex:index];
        [[CCModelChangeMonitor sharedInstance] listsWillUpdateUserData:@[list] send:YES];
        list.notify = @(enabled);
        [[CCLinotteCoreDataStack sharedInstance] saveContext];
        [[CCModelChangeMonitor sharedInstance] listsDidUpdateUserData:@[list] send:YES];
    }
}

#pragma mark provider methods

- (double)distanceForListItemAtIndex:(NSUInteger)index
{
    return [_provider distanceForListItemAtIndex:index];
}

- (double)angleForListItemAtIndex:(NSUInteger)index
{
    return [_provider angleForListItemAtIndex:index];
}

- (UIImage *)iconForListItemAtIndex:(NSUInteger)index
{
    return [_provider iconFormListItemAtIndex:index];
}

- (NSString *)nameForListItemAtIndex:(NSUInteger)index
{
    return [_provider nameForListItemAtIndex:index];
}

- (NSString *)infoForListItemAtIndex:(NSUInteger)index
{
    return [_provider infoForListItemAtIndex:index];
}

- (BOOL)notificationEnabledForListItemAtIndex:(NSUInteger)index
{
    return [_provider notificationEnabledForListItemAtIndex:index];
}

- (BOOL)deletableForListItemAtIndex:(NSUInteger)index
{
    return _deletableItems;
}

- (BOOL)orientationAvailableAtIndex:(NSUInteger)index
{
    return [_provider orientationAvailableAtIndex:index];
}

- (NSUInteger)numberOfListItems
{
    return [_provider numberOfListItems];
}

#pragma mark - CCListViewContentProviderDelegate methods

- (void)refreshCellsAtIndexes:(NSIndexSet *)indexSet
{
    CCListView *view = (CCListView *)self.view;
    
    [view reloadCellsAtIndexes:indexSet];
}

- (void)insertCellsAtIndexes:(NSIndexSet *)indexSet
{
    CCListView *view = (CCListView *)self.view;
    
    [view insertCellsAtIndexes:indexSet];
    [view removeEmptyView];
}

- (void)removeCellsAtIndexes:(NSIndexSet *)indexSet
{
    CCListView *view = (CCListView *)self.view;
    
    [view deleteCellsAtIndexes:indexSet];
    if ([_provider numberOfListItems] == 0)
        [view setupEmptyView];
}

- (void)sortOrderChanged
{
    CCListView *view = (CCListView *)self.view;
    
    [view reloadVisibleCells];
}

#pragma mark - CCListOutputViewControllerDelegate methods

#pragma mark - CCOutputViewControllerDelegate methods

@end
