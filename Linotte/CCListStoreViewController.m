//
//  CCListStoreViewController.m
//  Linotte
//
//  Created by stant on 09/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListStoreViewController.h"

#import <Reachability/Reachability.h>

#import <HexColors/HexColor.h>

#import "CCLinotteAPI.h"
#import "CCNetworkHandler.h"

#import "CCLocationMonitor.h"

#import "CCListInstallerViewController.h"
#import "CCListOutputViewController.h"

#import "CCList.h"
#import "CCListStoreView.h"


@implementation CCListStoreViewController
{
    NSMutableArray *_lists;
    NSUInteger _totalLists;
    
    CLLocation *_location;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lists = [@[] mutableCopy];
        
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
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.title = NSLocalizedString(@"LIST_STORE_SCREEN_NAME", @"");
    
    CCListStoreView *view = [CCListStoreView new];
    view.delegate = self;
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([[CCNetworkHandler sharedInstance] connectionAvailable]) {
        [((CCListStoreView *)self.view) reachable];
    } else {
        [((CCListStoreView *)self.view) unreachable];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [[CCLocationMonitor sharedInstance] addDelegate:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[CCLocationMonitor sharedInstance] removeDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - CCChildRootViewControllerProtocol methods

- (void)viewWillShow
{
}

- (void)viewWillHide
{
}

#pragma mark - Location methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    BOOL launchFetch = _location == nil;
    _location = [locations lastObject];
    
    if (launchFetch)
        [self loadLists:0];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[CCLocationMonitor sharedInstance] removeDelegate:self];
    });
}

#pragma mark - Data methods

- (void)loadLists:(NSUInteger)pageNumber
{
    [[CCLinotteAPI sharedInstance] fetchPublicLists:_location.coordinate completionBlock:^(BOOL success, NSArray *lists) {
        if (success) {
            [_lists addObjectsFromArray:lists];
            [((CCListStoreView *)self.view) firstLoad];
        }
    }];
}

#pragma mark - UIBarButtons target methods

- (void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIListStoreViewDelegate methods

- (void)listSelectedAtIndex:(NSUInteger)index
{
    NSDictionary *listDict = _lists[index];
    CCListInstallerViewController *listInstallerViewController = [[CCListInstallerViewController alloc] initWithIdentifier:listDict[@"identifier"]];
    listInstallerViewController.delegate = self;
    
    [self addChildViewController:listInstallerViewController];
    [((CCListStoreView *)self.view) addListInstallerView:listInstallerViewController.view];
    [listInstallerViewController didMoveToParentViewController:self];
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

- (NSString *)iconForListAtIndex:(NSUInteger)index
{
    NSDictionary *listDict = _lists[index];
    return listDict[@"icon"];
}

#pragma mark - CCListInstallerViewControllerDelegate

- (void)closeListInstaller:(CCListInstallerViewController *)sender
{
    [sender willMoveToParentViewController:nil];
    [((CCListStoreView *)self.view) removeListInstallerView:sender.view completionBlock:^{
        [sender removeFromParentViewController];
    }];
}

- (void)listInstaller:(CCListInstallerViewController *)sender listInstalled:(CCList *)list
{
    CCListOutputViewController *listOutputViewController = [[CCListOutputViewController alloc] initWithList:list listIsNew:YES];
    listOutputViewController.delegate = self;
    [self.navigationController pushViewController:listOutputViewController animated:YES];
}

#pragma mark - NSNotificationCenter methods

- (void)reachabilityChanged:(NSNotification *)notification
{
    Reachability *reachability = notification.object;
    if (reachability.isReachable) {
        [((CCListStoreView *)self.view) reachable];
    } else {
        [((CCListStoreView *)self.view) unreachable];
    }
}

@end
