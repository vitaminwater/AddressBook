//
//  CCOutputViewController.m
//  Linotte
//
//  Created by stant on 12/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCOutputViewController.h"

#import <HexColors/HexColor.h>

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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = _address.name;
    
    NSString *color = @"#6b6b6b";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithHexString:color], NSFontAttributeName: [UIFont fontWithName:@"Montserrat-Bold" size:23]};
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
}

- (void)appleMapRoute:(CCRouteType)type
{
    NSMutableString *url = [kCCAppleMapScheme mutableCopy];
    [url appendFormat:@"?daddr=%f,%f", _address.latitudeValue, _address.longitudeValue];
    [url appendFormat:@"&saddr=%f,%f", _currentLocation.coordinate.latitude, _currentLocation.coordinate.longitude];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
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

- (void)notificationEnable:(BOOL)enable
{
    _address.notify = @(enable);
    [[[RKManagedObjectStore defaultStore] mainQueueManagedObjectContext] saveToPersistentStore:NULL];
}

@end
