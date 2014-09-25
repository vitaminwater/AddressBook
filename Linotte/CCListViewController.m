//
//  CCListViewController.m
//  Linotte
//
//  Created by stant on 06/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListViewController.h"

#import <Mixpanel/Mixpanel.h>

#import <objc/runtime.h>

#import "CCAlertView.h"

#import "CCModelChangeMonitor.h"
#import "CCLocationMonitor.h"

#import "CCListViewContentProvider.h"

#import "CCGeohashHelper.h"

#import "NSString+CCLocalizedString.h"

#import "CCOutputViewController.h"
#import "CCListOutputViewController.h"

#import "CCRestKit.h"

#import "CCListView.h"

#import "CCAddress.h"
#import "CCList.h"

/*
 * Actual View controller implementation
 */

@interface CCListViewController ()

@property(nonatomic, strong)CLLocation *currentLocation;
@property(nonatomic, strong)CLHeading *currentHeading;

@end

@implementation CCListViewController

- (id)initWithProvider:(CCListViewContentProvider *)provider
{
    self = [super init];
    if (self) {
        _provider = provider;
    }
    return self;
}

- (void)dealloc
{
    [[CCLocationMonitor sharedInstance] removeDelegate:self];
}

- (void)loadView
{
    CCListView *listView = [CCListView new];
    listView.delegate = self;
    self.view = listView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[CCLocationMonitor sharedInstance] addDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    CCListView *listView = (CCListView *)self.view;
    [listView unselect];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[CCLocationMonitor sharedInstance] removeDelegate:self];
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
    [_provider resortListItems];
    [((CCListView *)self.view) reloadVisibleCells];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)heading
{
    _provider.currentHeading = heading;
    [((CCListView *)self.view) reloadVisibleCells];
}

#pragma mark - public methods

#pragma mark - CCAlertView target methods

- (void)alertViewDidSayYes:(CCAlertView *)sender
{
    NSUInteger index = [sender.userInfo integerValue];
    CCListItemType type = [_provider listItemTypeAtIndex:index];
    
    if (type == CCListItemTypeAddress) {
        NSError *error;
        NSManagedObjectContext *managedObjectContext = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
        CCAddress *address = ((CCAddress *)[_provider listItemContentAtIndex:index]);
        [[Mixpanel sharedInstance] track:@"Address deleted" properties:@{@"name": address.name ?: @"",
                                                                         @"address": address.address ?: @"",
                                                                         @"identifier": address.identifier ?: @""}];
        
        [managedObjectContext deleteObject:address];
        [managedObjectContext saveToPersistentStore:&error];
        [[CCModelChangeMonitor sharedInstance] removeAddress:address];
        
        [((CCListView *)self.view) showConfirmationHUD:NSLocalizedString(@"NOTIF_ADDRESS_DELETE_CONFIRM", @"")];
    } else if (type == CCListItemTypeList) {
        // CCList *list = (CCList *)[_addressContentProvider listItemContentAtIndex:[index unsignedIntegerValue]];
        // TODO
    }
    
    [CCAlertView closeAlertView:sender];
}

- (void)alertViewDidSayNo:(CCAlertView *)sender
{
    [CCAlertView closeAlertView:sender];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
        return;
    

}

#pragma mark - CCListViewDelegate methods

- (void)showOptionViewProgress:(CGFloat)pixels
{
    
}

- (void)showOptionView
{
    [_delegate showOptionView];
}

- (void)hideOptionViewProgress:(CGFloat)pixels
{
    
}

- (void)hideOptionView
{
    [_delegate hideOptionView];
}

- (UIView *)getEmptyView
{
    return [_delegate getEmptyView];
}

- (void)didSelectListItemAtIndex:(NSUInteger)index
{
    CCListItemType type = [_provider listItemTypeAtIndex:index];
    if (type == CCListItemTypeAddress) {
        CCAddress *address = ((CCAddress *)[_provider listItemContentAtIndex:index]);
        CCOutputViewController *outputViewController = [[CCOutputViewController alloc] initWithAddress:address];
        outputViewController.delegate = self;
        [self.navigationController pushViewController:outputViewController animated:YES];
    } else if (type == CCListItemTypeList) {
        CCList *list = (CCList *)[_provider listItemContentAtIndex:index];
        CCListOutputViewController *listOutputViewController = [[CCListOutputViewController alloc] initWithList:list];
        listOutputViewController.delegate = self;
        [self.navigationController pushViewController:listOutputViewController animated:YES];
    }
}

- (void)deleteListItemAtIndex:(NSUInteger)index
{
    NSString *alertTitle = [_provider listItemTypeAtIndex:index] == CCListItemTypeAddress ? NSLocalizedString(@"NOTIF_ADDRESS_DELETE", @"") : NSLocalizedString(@"NOTIF_LIST_DELETE", @"");
    
    CCAlertView *alertView = [CCAlertView showAlertViewWithText:alertTitle target:self okAction:@selector(alertViewDidSayYes:) cancelAction:@selector(alertViewDidSayNo:)];
    alertView.userInfo = @(index);
}

- (void)setNotificationEnabled:(BOOL)enabled atIndex:(NSUInteger)index
{
    NSManagedObjectContext *managedObjectContext = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    CCListItemType type = [_provider listItemTypeAtIndex:index];
    if (type == CCListItemTypeAddress) {
        CCAddress *address = ((CCAddress *)[_provider listItemContentAtIndex:index]);
        address.notify = @(enabled);
        [managedObjectContext saveToPersistentStore:NULL];
        [[CCModelChangeMonitor sharedInstance] updateAddress:address];
    } else if (type == CCListItemTypeList) {
        CCList *list = (CCList *)[_provider listItemContentAtIndex:index];
        list.notify = @(enabled);
        [managedObjectContext saveToPersistentStore:NULL];
        [[CCModelChangeMonitor sharedInstance] updateList:list];
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

- (BOOL)notificationEnabledForListItemAtIndex:(NSUInteger)index
{
    return [_provider notificationEnabledForListItemAtIndex:index];
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
}

- (void)removeCellsAtIndexes:(NSIndexSet *)indexSet
{
    CCListView *view = (CCListView *)self.view;
    
    [view deleteCellsAtIndexes:indexSet];
}

- (void)sortOrderChanged
{
    CCListView *view = (CCListView *)self.view;
    
    [view reloadVisibleCells];
}

#pragma mark - CCListOutputViewControllerDelegate methods

#pragma mark - CCOutputViewControllerDelegate methods

@end
