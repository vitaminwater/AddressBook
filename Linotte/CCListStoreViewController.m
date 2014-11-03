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
    
    CCListStoreView *view = [CCListStoreView new];
    view.delegate = self;
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"LIST_STORE_CONTROLLER_TITLE", @"");
    
    NSString *color = @"#6b6b6b";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithHexString:color], NSFontAttributeName: [UIFont fontWithName:@"Montserrat-Bold" size:23]};
    
    { // left bar button items
        CGRect backButtonFrame = CGRectMake(0, 0, 30, 30);
        UIButton *backButton = [UIButton new];
        [backButton setImage:[UIImage imageNamed:@"back_icon.png"] forState:UIControlStateNormal];
        backButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        backButton.frame = backButtonFrame;
        [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        
        UIBarButtonItem *emptyBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        emptyBarButtonItem.width = -10;
        self.navigationItem.leftBarButtonItems = @[emptyBarButtonItem, barButtonItem];
    }
    self.navigationItem.hidesBackButton = YES;
    
    if ([[CCNetworkHandler sharedInstance] connectionAvailable]) {
        [((CCListStoreView *)self.view) reachable];
    } else {
        [((CCListStoreView *)self.view) unreachable];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
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

#pragma mark - Location methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    BOOL launchFetch = _location == nil;
    _location = [locations lastObject];
    
    if (launchFetch)
        [self loadLists:0];
    
    [[CCLocationMonitor sharedInstance] removeDelegate:self];
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
    CCPublicListModel *list = _lists[index];
    CCListInstallerViewController *listInstallerViewController = [[CCListInstallerViewController alloc] initWithIdentifier:list.identifier];
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
    CCPublicListModel *list = _lists[index];
    return list.name;
}

- (NSString *)iconForListAtIndex:(NSUInteger)index
{
    CCPublicListModel *list = _lists[index];
    return list.icon;
}

#pragma mark - CCListInstallerViewControllerDelegate

- (void)closeListInstaller:(CCListInstallerViewController *)sender
{
    [sender willMoveToParentViewController:nil];
    [((CCListStoreView *)self.view) removeListInstallerView:sender.view completionBlock:^{
        [sender removeFromParentViewController];
    }];
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
