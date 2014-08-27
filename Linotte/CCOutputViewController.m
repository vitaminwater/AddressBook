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

#import "CCOutputView.h"

#import "CCRestKit.h"

#define kCCGoogleMapScheme @"comgooglemaps-x-callback://"
#define kCCAppleMapScheme @"http://maps.apple.com/"

@interface CCOutputViewController ()
{
    CLLocationManager *_locationManager;
    CLLocation *_currentLocation;
}

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
    }
    return self;
}

- (void)loadView
{
    CCOutputView *view = [[CCOutputView alloc] initWithDelegate:self];
    self.view = view;
    
    if (_addressIsNew)
        [view showIsNewMessage];
    
    [[Mixpanel sharedInstance] track:@"Address consult" properties:@{@"address": _address.name, @"address": _address.address}];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = _address.name;
    
    NSString *color = @"#6b6b6b";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithHexString:color], NSFontAttributeName: [UIFont fontWithName:@"Montserrat-Bold" size:23]};
    
    CGRect navigationBarFrame = self.navigationController.navigationBar.bounds;
    
    { // right bar button items
        CGRect settingsButtonFrame = CGRectMake(0, 0, 35, 35);
        settingsButtonFrame.origin.x = navigationBarFrame.size.width - settingsButtonFrame.size.width - 4;
        settingsButtonFrame.origin.y = navigationBarFrame.size.height - settingsButtonFrame.size.height - 4;
        UIButton *settingsButton = [UIButton new];
        [settingsButton setImage:[UIImage imageNamed:@"settings_icon.png"] forState:UIControlStateNormal];
        settingsButton.frame = settingsButtonFrame;
        [settingsButton addTarget:self action:@selector(settingsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.navigationController.navigationBar addSubview:settingsButton];
    }
    
    { // left bar button items
        CGRect backButtonFrame = CGRectMake(0, 0, 30, 30);
        backButtonFrame.origin.y = navigationBarFrame.size.height - backButtonFrame.size.height - 8;
        UIButton *backButton = [UIButton new];
        [backButton setImage:[UIImage imageNamed:@"back_icon.png"] forState:UIControlStateNormal];
        backButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        backButton.frame = backButtonFrame;
        [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.navigationController.navigationBar addSubview:backButton];
    }
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
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

#pragma mark - UIBarButtons target methods

- (void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)settingsButtonPressed:(id)sender
{
    CCOutputView *view = (CCOutputView *)self.view;
    [view showSettingsView];
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

- (void)launchRoute:(CCRouteType)type
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:kCCGoogleMapScheme]])
        [self googleRoute:type];
    else
        [self appleMapRoute:type];
}

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

- (void)setNotificationEnabled:(BOOL)enable
{
    _address.notify = @(enable);
    [[[RKManagedObjectStore defaultStore] mainQueueManagedObjectContext] saveToPersistentStore:NULL];
    
    [[Mixpanel sharedInstance] track:@"Notification enable" properties:@{@"name": _address.name, @"address": _address.address, @"identifier": _address.identifier, @"enabled": @(enable)}];
}

@end
