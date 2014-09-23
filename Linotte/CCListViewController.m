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

@property(nonatomic, strong)CLLocationManager *locationManager;
@property(nonatomic, strong)CLLocation *currentLocation;
@property(nonatomic, strong)CLHeading *currentHeading;

@end

@implementation CCListViewController

- (id)initWithProvider:(CCListViewContentProvider *)provider
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        _provider = provider;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_locationManager == nil) {
        _locationManager = [CLLocationManager new];
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.delegate = self;
    }
    [_locationManager startUpdatingLocation];
    [_locationManager startUpdatingHeading];
    
    CCListView *listView = (CCListView *)self.view;
    [listView unselect];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_locationManager stopUpdatingLocation];
    [_locationManager stopUpdatingHeading];
    
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

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
        return;
    
    NSUInteger index = [objc_getAssociatedObject(alertView, @"index") unsignedIntegerValue];
    CCListItemType type = [_provider listItemTypeAtIndex:index];
    
    if (type == CCListItemTypeAddress) {
        NSError *error;
        NSManagedObjectContext *managedObjectContext = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
        CCAddress *address = ((CCAddress *)[_provider listItemContentAtIndex:index]);
        [[Mixpanel sharedInstance] track:@"Address deleted" properties:@{@"name": address.name ?: @"",
                                                                         @"address": address.address ?: @"",
                                                                         @"identifier": address.identifier ?: @""}];
        
        [managedObjectContext deleteObject:address];
        if ([managedObjectContext saveToPersistentStore:&error] == NO) {
            NSLog(@"%@", error);
            return;
        }
    } else if (type == CCListItemTypeList) {
        // CCList *list = (CCList *)[_addressContentProvider listItemContentAtIndex:[index unsignedIntegerValue]];
        // TODO
    }
}

#pragma mark - CCListViewDelegate methods

- (void)showOptionView
{
    [_delegate showOptionView];
}

- (void)hideOptionView
{
    [_delegate hideOptionView];
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
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NOTIF_ADDELETE", @"") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"NOTIF_ADDELETE_N", @"") otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
    [alertView show];
    
    objc_setAssociatedObject(alertView, @"index", @(index), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setNotificationEnabled:(BOOL)enabled atIndex:(NSUInteger)index
{
    NSManagedObjectContext *managedObjectContext = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    CCListItemType type = [_provider listItemTypeAtIndex:index];
    if (type == CCListItemTypeAddress) {
        CCAddress *address = ((CCAddress *)[_provider listItemContentAtIndex:index]);
        address.notify = @(enabled);
        [managedObjectContext saveToPersistentStore:NULL];
        
    } else if (type == CCListItemTypeList) {
        CCList *list = (CCList *)[_provider listItemContentAtIndex:index];
        list.notify = @(enabled);
        [managedObjectContext saveToPersistentStore:NULL];
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

#pragma mark - UINotificationCenter methods

- (void)applicationActive:(NSNotification *)note
{
    [_locationManager startUpdatingLocation];
    [_locationManager startUpdatingHeading];
}

- (void)applicationBackground:(NSNotification *)note
{
    [_locationManager stopUpdatingLocation];
    [_locationManager stopUpdatingHeading];
}

@end
