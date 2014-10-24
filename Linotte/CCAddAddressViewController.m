//
//  CCAddViewController.m
//  Linotte
//
//  Created by stant on 06/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCAddAddressViewController.h"

#import <Reachability/Reachability.h>

#import <MBProgressHUD/MBProgressHUD.h>

#import <Mixpanel/Mixpanel.h>

#import <geohash/geohash.h>

#import "CCAddressNameAutoCompleter.h"

#import "CCCoreDataStack.h"

#import "CCModelChangeMonitor.h"

#import "CCGeohashHelper.h"
#import "CCNetworkHandler.h"

#import "CCAddAddressView.h"

#import "CCAddress.h"
#import "CCCategory.h"
#import "CCList.h"

/**
 * View controller implementation
 */

@implementation CCAddAddressViewController
{
    CCAddressNameAutoCompleter *_autoComplete;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _autoComplete = [CCAddressNameAutoCompleter new];
        _autoComplete.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reachabilityChanged:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView
{
    CCAddAddressView *addView = [CCAddAddressView new];
    addView.delegate = self;
    self.view = addView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - CCAddressNameAutocompletedDelegate methods

- (void)autocompeteWaitingLocation:(id)sender
{
    [(CCAddAddressView *)self.view showLoading:NSLocalizedString(@"AWAITING_LOCATION", @"")];
}

- (void)autocompleteStarted:(id)sender
{
    [(CCAddAddressView *)self.view showLoading:NSLocalizedString(@"LOADING", @"")];
}

- (void)autocompleteResultsRecieved:(id)sender
{
    [((CCAddAddressView *)self.view) reloadAutocompletionResults];
}

- (void)autocompleteEnded:(id)sender
{
    [(CCAddAddressView *)self.view hideLoading];
}

#pragma mark - CCAddAddressViewDelegate methods

- (void)reduceAddView
{
    [_delegate reduceAddView];
    [_autoComplete stopAutoComplete];
    
    [(CCAddAddressView *)self.view hideLoading];
}

- (void)autocompleteName:(NSString *)name
{
    [_autoComplete autocompleteAddressName:name];
    [_delegate expandAddView];
}

- (NSString *)nameForAutocompletionResultAtIndex:(NSUInteger)index
{
    CCAddViewAutocompletionResult *autocompletionResult = [_autoComplete autocompletionResultAtIndex:index];
    return autocompletionResult.name;
}

- (NSString *)addressForAutocompletionResultAtIndex:(NSUInteger)index
{
    CCAddViewAutocompletionResult *autocompletionResult = [_autoComplete autocompletionResultAtIndex:index];
    return autocompletionResult.address;
}

- (NSUInteger)numberOfAutocompletionResults
{
    return [_autoComplete numberOfAutocompletionResults];
}

- (void)autocompletionResultSelectedAtIndex:(NSUInteger)index
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    CCAddress *address = [CCAddress insertInManagedObjectContext:managedObjectContext];
    CCAddViewAutocompletionResult *autocompletionResult = [_autoComplete autocompletionResultAtIndex:index];
    
    address.name = autocompletionResult.name;
    address.address = autocompletionResult.address;
    address.provider = autocompletionResult.provider;
    address.providerId = autocompletionResult.providerId;
    address.date = [NSDate date];
    address.latitude = @(autocompletionResult.coordinates.latitude);
    address.longitude = @(autocompletionResult.coordinates.longitude);
    
    address.geohash = [CCGeohashHelper geohashFromCoordinates:autocompletionResult.coordinates];
    
    for (CCAddViewAutocompletionResultCategorie *categorie in autocompletionResult.categories) {
        CCCategory *categorieModel = [CCCategory insertInManagedObjectContext:managedObjectContext];
        categorieModel.identifier = categorie.identifier;
        categorieModel.name = categorie.name;
        [address addCategoriesObject:categorieModel];
    }
    
    [_delegate preSaveAddress:address];
    [[CCCoreDataStack sharedInstance] saveContext];
    [[CCModelChangeMonitor sharedInstance] addressDidAdd:address];
    [_delegate postSaveAddress:address];
    
    [self reduceAddView];
    [[Mixpanel sharedInstance] track:@"Address added" properties:@{@"name": address.name, @"address": address.address, @"provider": address.provider, @"providerId": address.providerId}];
}

#pragma mark - NSNotificationCenter methods

- (void)reachabilityChanged:(NSNotification *)notification
{
    Reachability *reachability = notification.object;
    if (reachability.isReachable) {
        [((CCAddAddressView *)self.view) enableField];
    } else {
        [((CCAddAddressView *)self.view) disableField];
    }
}

@end
