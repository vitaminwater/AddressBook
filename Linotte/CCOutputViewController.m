//
//  CCOutputViewController.m
//  Linotte
//
//  Created by stant on 12/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCOutputViewController.h"

#import <HexColors/HexColor.h>

#import <Mixpanel/Mixpanel.h>

#import "UIView+CCShowSettingsView.h"
#import "CCAddressSettingsViewController.h"
#import "CCAddressListSettingsViewController.h"

#import "CCOutputView.h"

#import "CCRestKit.h"

#import "CCAddress.h"
#import "CCList.h"

#define kCCGoogleMapScheme @"comgooglemaps-x-callback://"
#define kCCAppleMapScheme @"http://maps.apple.com/"

@interface CCOutputViewController ()

@property(nonatomic, strong)CLLocationManager *locationManager;
@property(nonatomic, strong)CLLocation *currentLocation;

@property(nonatomic, strong)UIButton *settingsButton;

@property(nonatomic, assign)BOOL addressIsNew;
@property(nonatomic, strong)CCAddress *address;
@property(nonatomic, assign)CLLocationDistance distance;

@end

@implementation CCOutputViewController

- (id)initWithAddress:(CCAddress *)address addressIsNew:(BOOL)addressIsNew
{
    self = [self initWithAddress:address];
    if (self) {
        _addressIsNew = addressIsNew;
    }
    return self;
}

- (id)initWithAddress:(CCAddress *)address
{
    self = [super init];
    if (self) {
        self.address = address;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView
{
    CCOutputView *view = [[CCOutputView alloc] initWithDelegate:self];
    self.view = view;
    
    if (_addressIsNew)
        [view showIsNewMessage];
    
    [[Mixpanel sharedInstance] track:@"Address consult" properties:@{@"name": _address.name, @"address": _address.address, @"identifier": _address.identifier ?: @"nb"}];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = _address.name;
    
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
    
    { // right bar button items
        CGRect settingsButtonFrame = CGRectMake(0, 0, 30, 30);
        _settingsButton = [UIButton new];
        [_settingsButton setImage:[UIImage imageNamed:@"settings_icon.png"] forState:UIControlStateNormal];
        _settingsButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        _settingsButton.frame = settingsButtonFrame;
        [_settingsButton addTarget:self action:@selector(settingsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_settingsButton];
        
        self.navigationItem.rightBarButtonItems = @[barButtonItem];
    }
    
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController setNavigationBarHidden:NO animated:animated];
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
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_locationManager stopUpdatingLocation];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

#pragma mark - UIBarButtons target methods

- (void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)settingsButtonPressed:(id)sender
{
    CCAddressSettingsViewController *addressSettingsViewController = [[CCAddressSettingsViewController alloc] initWithAddress:_address];
    addressSettingsViewController.delegate = self;
    [self addChildViewController:addressSettingsViewController];
    
    [self.view showSettingsView:addressSettingsViewController.view];
    
    [addressSettingsViewController didMoveToParentViewController:self];
    
    _settingsButton.enabled = NO;
}

#pragma mark - route methods

- (void)googleRoute:(CCRouteType)type
{
    NSDictionary *modes = @{@(CCRouteTypeCar) : @"driving", @(CCRouteTypeTrain) : @"transit", @(CCRouteTypeWalk) : @"walking", @(CCRouteTypeBicycling) : @"bicycling"};
    
    NSMutableString *url = [kCCGoogleMapScheme mutableCopy];
    [url appendFormat:@"?daddr=%f,%f", _address.latitudeValue, _address.longitudeValue];
    [url appendFormat:@"&directionsmode=%@", modes[@(type)]];
    [url appendFormat:@"&x-source=Linotte"];
    [url appendFormat:@"&x-success=comlinotte://?resume=true"];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    
    [[Mixpanel sharedInstance] track:@"Google route" properties:@{@"mode": modes[@(type)], @"name": _address.name, @"address": _address.address, @"identifier": _address.identifier}];
}

- (void)appleMapRoute:(CCRouteType)type
{
    NSMutableString *url = [kCCAppleMapScheme mutableCopy];
    [url appendFormat:@"?daddr=%f,%f", _address.latitudeValue, _address.longitudeValue];
    [url appendFormat:@"&saddr=%f,%f", _currentLocation.coordinate.latitude, _currentLocation.coordinate.longitude];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    
    [[Mixpanel sharedInstance] track:@"Apple route" properties:@{@"name": _address.name, @"address": _address.address, @"identifier": _address.identifier}];
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    _currentLocation = location;
    
    CLLocation *coordinate = [[CLLocation alloc] initWithLatitude:_address.latitudeValue longitude:_address.longitudeValue];
    self.distance = [_currentLocation distanceFromLocation:coordinate];
    [((CCOutputView *)self.view) updateValues];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithHexString:((CCOutputView *)self.view).currentColor], NSFontAttributeName: [UIFont fontWithName:@"Montserrat-Bold" size:23]};
}

#pragma mark - CCoutputViewDelegate

#pragma mark route

- (void)launchRoute:(CCRouteType)type
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:kCCGoogleMapScheme]])
        [self googleRoute:type];
    else
        [self appleMapRoute:type];
}

#pragma mark address display

- (double)addressDistance
{
    return self.distance;
}

- (NSString *)addressName
{
    return _address.name;
}

- (NSString *)addressString
{
    return _address.address;
}

- (NSString *)addressProvider
{
    return _address.provider;
}

- (double)addressLatitude {
    return _address.latitudeValue;
}

- (double)addressLongitude
{
    return _address.longitudeValue;
}

- (BOOL)notificationEnabled
{
    return [_address.notify boolValue];
}

#pragma mark - CCSettingsViewControllerDelegate methods

- (void)settingsViewControllerDidEnd:(UIViewController *)sender
{
    [sender willMoveToParentViewController:nil];
    [self.view hideSettingsView:sender.view];
    [sender removeFromParentViewController];
    
    if ([sender isKindOfClass:[CCAddressSettingsViewController class]])
        _settingsButton.enabled = YES;
}

#pragma mark CCAddressSettingsViewControllerDelegate methods

- (void)showListSettings
{
    CCAddressListSettingsViewController *addressListSettingsViewController = [[CCAddressListSettingsViewController alloc] initWithAddress:_address];
    addressListSettingsViewController.delegate = self;
    [self addChildViewController:addressListSettingsViewController];
    
    [self.view showSettingsView:addressListSettingsViewController.view];
    
    [addressListSettingsViewController didMoveToParentViewController:self];
}

#pragma mark CCAddressListSettingsViewControllerDelegate methods

#pragma mark - UINotificationCenter methods

- (void)applicationActive:(NSNotification *)note
{
    [_locationManager startUpdatingLocation];
}

- (void)applicationBackground:(NSNotification *)note
{
    [_locationManager stopUpdatingLocation];
}

@end
