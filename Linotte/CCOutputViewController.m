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

#import "CCLocationMonitor.h"
#import "CCModelChangeMonitor.h"
#import "CCLinotteCoreDataStack.h"

#import "UIView+CCShowSettingsView.h"
#import "CCFirstAddressDisplaySettingsViewController.h"
#import "CCAddressSettingsViewController.h"
#import "CCAddressListSettingsViewController.h"

#import "CCOutputView.h"

#import "CCBaseMetaWidget.h"

#import "CCMetaProtocol.h"
#import "CCMeta.h"

#import "CCAddress.h"
#import "CCAddressMeta.h"
#import "CCList.h"

#define kCCGoogleMapScheme @"comgooglemaps-x-callback://"
#define kCCAppleMapScheme @"http://maps.apple.com/"


@implementation CCOutputViewController
{
    CLLocation *_currentLocation;
    
    UIButton *_settingsButton;
    
    BOOL _addressIsNew;
    CCAddress *_address;
    CLLocationDistance _distance;
}

@dynamic addressNote;

- (instancetype)initWithAddress:(CCAddress *)address addressIsNew:(BOOL)addressIsNew
{
    self = [self initWithAddress:address];
    if (self) {
        _addressIsNew = addressIsNew;
    }
    return self;
}

- (instancetype)initWithAddress:(CCAddress *)address
{
    self = [super init];
    if (self) {
        _address = address;
    }
    return self;
}

- (void)dealloc
{
    [[CCLocationMonitor sharedInstance] removeDelegate:self];
}

- (void)loadView
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;

    CCOutputView *view = [CCOutputView new];
    
    NSArray *hoursMetas = [_address metasForActions:@[@"hours"]];
    [view setHoursMetas:hoursMetas];
    
    NSArray *infosViewMetas = [_address metasForActions:@[@"photos", @"display"]];
    [view setDisplayMetas:infosViewMetas];
    
    NSArray *externalMetas = [_address metasForActions:@[@"external", @"social"]];
    [view setExternalMetas:externalMetas];
    
    CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake(_address.latitudeValue, _address.longitudeValue);
    [view setAddressInfos:[_address.name capitalizedString] address:[_address.address capitalizedString] provider:_address.provider coordinates:coordinates];
    view.delegate = self;
    self.view = view;
    
    if (_addressIsNew) {
        CCFirstAddressDisplaySettingsViewController *firstAddressDisplaySettingsViewController = [[CCFirstAddressDisplaySettingsViewController alloc] initWithAddress:_address];
        firstAddressDisplaySettingsViewController.delegate = self;
        [self addChildViewController:firstAddressDisplaySettingsViewController];
        
        [self.view showSettingsView:firstAddressDisplaySettingsViewController.view fullScreen:NO];
        
        [firstAddressDisplaySettingsViewController didMoveToParentViewController:self];
    }
    
    @try {
        [[Mixpanel sharedInstance] track:@"Address consult" properties:@{@"name": _address.name, @"address": _address.address, @"identifier": _address.identifier ?: @"NEW"}];
    }
    @catch(NSException *e) {
        CCLog(@"%@", e);
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [_address.name capitalizedString];
    
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
    
    [[CCLocationMonitor sharedInstance] addDelegate:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[CCLocationMonitor sharedInstance] removeDelegate:self];
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
    
    [self.view showSettingsView:addressSettingsViewController.view fullScreen:NO];
    
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
    
    NSString *identifier = _address.identifier ?: @"NEW";
    @try {
        [[Mixpanel sharedInstance] track:@"Google route" properties:@{@"mode": modes[@(type)], @"name": _address.name, @"address": _address.address, @"identifier": identifier}];
    }
    @catch(NSException *e) {
        CCLog(@"%@", e);
    }
}

- (void)appleMapRoute:(CCRouteType)type
{
    NSMutableString *url = [kCCAppleMapScheme mutableCopy];
    [url appendFormat:@"?daddr=%f,%f", _address.latitudeValue, _address.longitudeValue];
    [url appendFormat:@"&saddr=%f,%f", _currentLocation.coordinate.latitude, _currentLocation.coordinate.longitude];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    
    NSString *identifier = _address.identifier ?: @"NEW";
    @try {
        [[Mixpanel sharedInstance] track:@"Apple route" properties:@{@"name": _address.name, @"address": _address.address, @"identifier": identifier}];
    }
    @catch(NSException *e) {
        CCLog(@"%@", e);
    }
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CCOutputView *view = (CCOutputView *)self.view;
    CLLocation *location = [locations lastObject];
    _currentLocation = location;
    
    CLLocation *coordinate = [[CLLocation alloc] initWithLatitude:_address.latitudeValue longitude:_address.longitudeValue];
    _distance = [_currentLocation distanceFromLocation:coordinate];
    [view setDistance:_distance];
    
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

- (void)setAddressNote:(NSString *)addressNote
{
    NSString *newNote = [addressNote stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([newNote isEqualToString:_address.note])
        return;
    
    _address.note = newNote;
    [[CCLinotteCoreDataStack sharedInstance] saveContext];
    [[CCModelChangeMonitor sharedInstance] addressesDidUpdateUserData:@[_address] send:YES];
}

- (NSString *)addressNote
{
    return _address.note;
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
    
    [self.view showSettingsView:addressListSettingsViewController.view fullScreen:YES];
    
    [addressListSettingsViewController didMoveToParentViewController:self];
}

#pragma mark CCAddressListSettingsViewControllerDelegate methods

@end