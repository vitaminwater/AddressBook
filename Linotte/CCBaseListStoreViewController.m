//
//  CCBaseListStoreViewController.m
//  Linotte
//
//  Created by stant on 04/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import "CCBaseListStoreViewController.h"

#import <AFNetworking/AFNetworkReachabilityManager.h>
#import <HexColors/HexColor.h>

#import "CCLocationMonitor.h"

#import "CCListInstallerViewController.h"

#import "CCBaseListStoreView.h"

@implementation CCBaseListStoreViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reachabilityChanged:)
                                                     name:AFNetworkingReachabilityDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    NSString *color = @"#6b6b6b";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithHexString:color], NSFontAttributeName: [UIFont fontWithName:@"Montserrat-Bold" size:23]};
    
    [self updateReachableState];
}

- (CCBaseListStoreView *)listStoreView
{
    return (CCBaseListStoreView *)self.view;
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

- (void)showListInstaller:(NSDictionary *)listDict
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kCCShowListInstallerNotification object:listDict];
}

- (void)updateReachableState
{
    if ([AFNetworkReachabilityManager sharedManager].reachable) {
        [self.listStoreView reachable];
    } else {
        [self.listStoreView unreachable];
    }
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
        [self loadData:0];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[CCLocationMonitor sharedInstance] removeDelegate:self];
    });
}

#pragma mark - Data methods

- (void)loadData:(NSUInteger)pageNumber
{
}

#pragma mark - UIBarButtons target methods

- (void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - CCListInstallerViewControllerDelegate

#pragma mark - NSNotificationCenter methods

- (void)reachabilityChanged:(NSNotification *)notification
{
    [self updateReachableState];
}

@end
