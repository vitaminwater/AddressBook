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

#import "CCMetaContainerView.h"

#import "NSString+CCLocalizedString.h"

#import "CCAddressSettingsView.h"
#import "CCAddressListSettingsView.h"


@implementation CCOutputView
{
    GMSMarker *_marker;
    GMSMapView *_mapView;

    CCAddressSettingsView *_addressSettingsView;
    CCAddressListSettingsView *_listSettingsView;
    
    CCMetaContainerView *_metaContainerView;
    UITabBar *_tabBar;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.opaque = YES;

        [self setupMap];
        [self setupButtons];
        [self setupInfoView];
        [self setupLayout];
    }
    return self;
}

- (void)setupMap
{
    _mapView = [GMSMapView new];
    _mapView.myLocationEnabled = YES;
    _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _mapView.frame = self.bounds;
    [self addSubview:_mapView];
    
    _marker = [[GMSMarker alloc] init];
    _marker.icon = [UIImage imageNamed:@"gmap_pin_neutral"];;
    _marker.map = _mapView;
}

- (void)setupInfoView
{
    _metaContainerView = [CCMetaContainerView new];
    _metaContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    _metaContainerView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
    
    [self addSubview:_metaContainerView];
}

- (void)setupButtons
{
    _tabBar = [UITabBar new];
    _tabBar.translatesAutoresizingMaskIntoConstraints = NO;
    _tabBar.delegate = self;
    
    UITabBarItem *trainItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"ROUTE_TRAIN", @"") image:[UIImage imageNamed:@"train"] selectedImage:nil];
    UITabBarItem *carItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"ROUTE_CAR", @"") image:[UIImage imageNamed:@"car"] selectedImage:nil];
    UITabBarItem *bicycleItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"ROUTE_BICYCLE", @"") image:[UIImage imageNamed:@"bicycle"] selectedImage:nil];
    UITabBarItem *walkItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"ROUTE_WALK", @"") image:[UIImage imageNamed:@"walk"] selectedImage:nil];
    
    _tabBar.items = @[trainItem, carItem, bicycleItem, walkItem];
    [self addSubview:_tabBar];
}

- (void)setupLayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_metaContainerView, _tabBar);
    {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_metaContainerView]|" options:0 metrics:nil views:views];
        [self addConstraints:horizontalConstraints];
    }
    
    {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tabBar]|" options:0 metrics:nil views:views];
        [self addConstraints:horizontalConstraints];
        
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_metaContainerView][_tabBar]|" options:0 metrics:nil views:views];
        [self addConstraints:verticalConstraints];
    }
}

/*- (void)updateValues
{
    // info view
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
        
        NSString *distanceUnit = addressDistance > 1000 ? @"km" : @"m";
        double displayDistance = addressDistance > 1000 ? addressDistance / 1000 : addressDistance;
        NSString *string = [NSString stringWithFormat:@"%@\n%@\n%.02f %@\n%@ %@", addressName, addressString, displayDistance, distanceUnit, NSLocalizedString(@"PROVIDER_FROM", @""), [providerName capitalizedString]];
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:string];
        [attributedText setAttributes:@{NSFontAttributeName: titleFont, NSForegroundColorAttributeName: [UIColor colorWithHexString:color]} range:NSMakeRange(0, [addressName length])];
        [attributedText setAttributes:@{NSFontAttributeName: detailFont} range:NSMakeRange([addressName length], [string length] - [addressName length])];
        
        [_metaContainerView setAttributedText:attributedText];
    }
    
    // map view
}*/

- (void)addMeta:(id<CCMetaProtocol>)meta
{
    [_metaContainerView addMeta:meta];
}

- (void)updateMeta:(id<CCMetaProtocol>)meta
{
    [_metaContainerView updateMeta:meta];
}

#pragma mark - UITabBarDelegate methods

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    [_delegate launchRoute:[tabBar.items indexOfObject:item]];
}

#pragma mark - setter methods

- (void)setDelegate:(id<CCOutputViewDelegate>)delegate
{
    _delegate = delegate;

    CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake([_delegate addressLatitude], [_delegate addressLongitude]);
    [_marker setPosition:coordinates];
    _marker.snippet = [_delegate addressString];
    _marker.title = [_delegate addressName];
    
    GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithTarget:coordinates zoom:14];
    _mapView.camera = cameraPosition;
}

@end
