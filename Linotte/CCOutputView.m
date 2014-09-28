//
//  CCOutputView.m
//  Linotte
//
//  Created by stant on 12/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCOutputView.h"

#import <HexColors/HexColor.h>
#import <GoogleMaps/GoogleMaps.h>
#import <MBProgressHUD/MBProgressHUD.h>

#import "NSString+CCLocalizedString.h"

#import "CCAddressSettingsView.h"
#import "CCAddressListSettingsView.h"


@implementation CCOutputView
{
    GMSMarker *_marker;
    GMSMapView *_mapView;
    CCAddressSettingsView *_addressSettingsView;
    CCAddressListSettingsView *_listSettingsView;
    UITextView *_infoView;
}

- (id)initWithDelegate:(id<CCOutputViewDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.backgroundColor = [UIColor whiteColor];
        [self setupMap];
        [self setupButtons];
        [self setupInfoView];
    }
    return self;
}

- (void)setupMap
{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[_delegate addressLatitude]
                                                            longitude:[_delegate addressLongitude]
                                                                 zoom:14];
    GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView.myLocationEnabled = YES;
    mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    mapView.frame = self.bounds;
    [self addSubview:mapView];
    
    _marker = [[GMSMarker alloc] init];
    _marker.position = camera.target;
    _marker.snippet = [_delegate addressName];
    _marker.title = [_delegate addressName];
    _marker.map = mapView;
}

- (void)setupInfoView
{
    _infoView = [UITextView new];
    _infoView.translatesAutoresizingMaskIntoConstraints = NO;
    _infoView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
    _infoView.editable = NO;
    _infoView.scrollEnabled = NO;
    
    [self addSubview:_infoView];
    {
        NSDictionary *views = NSDictionaryOfVariableBindings(_infoView);
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_infoView]|" options:0 metrics:nil views:views];
        [self addConstraints:horizontalConstraints];
        
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_infoView]-(==48)-|" options:0 metrics:nil views:views];
        [self addConstraints:verticalConstraints];
    }
    [self updateValues];
}

- (void)setupButtons
{
    UITabBar *tabBar = [UITabBar new];
    tabBar.translatesAutoresizingMaskIntoConstraints = NO;
    tabBar.delegate = self;
    
    UITabBarItem *trainItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"ROUTE_TRAIN", @"") image:[UIImage imageNamed:@"train"] selectedImage:nil];
    UITabBarItem *carItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"ROUTE_CAR", @"") image:[UIImage imageNamed:@"car"] selectedImage:nil];
    UITabBarItem *bicycleItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"ROUTE_BICYCLE", @"") image:[UIImage imageNamed:@"bicycle"] selectedImage:nil];
    UITabBarItem *walkItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"ROUTE_WALK", @"") image:[UIImage imageNamed:@"walk"] selectedImage:nil];
    
    tabBar.items = @[trainItem, carItem, bicycleItem, walkItem];
    [self addSubview:tabBar];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(tabBar);
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tabBar]|" options:0 metrics:nil views:views];
    [self addConstraints:horizontalConstraints];
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[tabBar]|" options:0 metrics:nil views:views];
    [self addConstraints:verticalConstraints];
}

- (void)updateValues
{
    NSString *addressName = [_delegate addressName];
    NSString *addressString = [_delegate addressString];
    double addressDistance = [_delegate addressDistance];
    NSString *providerName = [_delegate addressProvider];
    
    NSString *color = @"#6b6b6b";
    NSString *iconName = @"gmap_pin_neutral";
    if (addressDistance > 0) {
        NSArray *distanceColors = kCCLinotteColors;
        int distanceColorIndex = addressDistance / 500;
        distanceColorIndex = MIN(distanceColorIndex, (int)[distanceColors count] - 1);
        color = distanceColors[distanceColorIndex];
        
        iconName = [NSString stringWithFormat:@"gmap_pin_%@", [color substringFromIndex:1]];
        _currentColor = color;
    }

    _marker.icon = [UIImage imageNamed:iconName];
    
    UIFont *titleFont = [UIFont fontWithName:@"Montserrat-Bold" size:20];
    UIFont *detailFont = [UIFont fontWithName:@"Futura-Book" size:14];
    NSString *string = [NSString stringWithFormat:@"%@\n%@\n%.02f m\n%@ %@", addressName, addressString, addressDistance, NSLocalizedString(@"PROVIDER_FROM", @""), [providerName capitalizedString]];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedText setAttributes:@{NSFontAttributeName: titleFont, NSForegroundColorAttributeName: [UIColor colorWithHexString:color]} range:NSMakeRange(0, [addressName length])];
    [attributedText setAttributes:@{NSFontAttributeName: detailFont} range:NSMakeRange([addressName length], [string length] - [addressName length])];
    
    [_infoView setAttributedText:attributedText];
}

#pragma mark - UITabBarDelegate methods

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    [_delegate launchRoute:[tabBar.items indexOfObject:item]];
}

@end
