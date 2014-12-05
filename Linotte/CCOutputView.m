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
    BOOL _metaExpanded;
    UIImageView *_expandIcon;
    
    GMSMarker *_marker;
    GMSMapView *_mapView;

    CCAddressSettingsView *_addressSettingsView;
    CCAddressListSettingsView *_listSettingsView;
    
    UIView *_infosView;
    UILabel *_nameLabel;
    UILabel *_addressLabel;
    UILabel *_distanceLabel;
    UILabel *_providerLabel;
    UIScrollView *_metaScrollView;
    CCMetaContainerView *_metaContainerView;
    UITabBar *_tabBar;
    
    NSLayoutConstraint *_topInfosViewConstraint;
    NSLayoutConstraint *_bottomInfosViewContraint;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.opaque = YES;
        _metaExpanded = NO;
        
        {
            UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureRecognizer:)];
            swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
            [self addGestureRecognizer:swipeGestureRecognizer];
        }
        
        {
            UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureRecognizer:)];
            swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
            [self addGestureRecognizer:swipeGestureRecognizer];
        }
        
        {
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)];
            [self addGestureRecognizer:tapGestureRecognizer];
        }

        [self setupMap];
        [self setupInfoView];
        [self setupButtons];
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
    _infosView = [UIView new];
    _infosView.translatesAutoresizingMaskIntoConstraints = NO;
    _infosView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
    [self addSubview:_infosView];
    
    _expandIcon = [UIImageView new];
    _expandIcon.translatesAutoresizingMaskIntoConstraints = NO;
    _expandIcon.image = [UIImage imageNamed:@"expand_icon"];
    _expandIcon.backgroundColor = [UIColor clearColor];
    _expandIcon.contentMode = UIViewContentModeCenter;
    [_infosView addSubview:_expandIcon];
    
    _nameLabel = [UILabel new];
    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _nameLabel.textColor = [UIColor darkGrayColor];
    _nameLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:18];
    _nameLabel.numberOfLines = 0;
    [_infosView addSubview:_nameLabel];
    
    _addressLabel = [UILabel new];
    _addressLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _addressLabel.textColor = [UIColor darkGrayColor];
    _addressLabel.font = [UIFont fontWithName:@"Futura-Book" size:15];
    _addressLabel.numberOfLines = 0;
    [_infosView addSubview:_addressLabel];
    
    _distanceLabel = [UILabel new];
    _distanceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _distanceLabel.textColor = [UIColor darkGrayColor];
    _distanceLabel.font = [UIFont fontWithName:@"Futura-Book" size:16];
    _distanceLabel.text = NSLocalizedString(@"DISTANCE_UNAVAILABLE", @"");
    [_infosView addSubview:_distanceLabel];
    
    _providerLabel = [UILabel new];
    _providerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _providerLabel.textColor = [UIColor darkGrayColor];
    _providerLabel.font = [UIFont fontWithName:@"Futura-Book" size:15];
    _providerLabel.numberOfLines = 0;
    [_infosView addSubview:_providerLabel];
    
    _metaScrollView = [UIScrollView new];
    _metaScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [_infosView addSubview:_metaScrollView];
    
    _metaContainerView = [CCMetaContainerView new];
    _metaContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [_metaScrollView addSubview:_metaContainerView];
    
    // _metaContainerView constraints
    {
        NSDictionary *views = NSDictionaryOfVariableBindings(_metaContainerView, _metaScrollView);
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_metaContainerView(==_metaScrollView)]|" options:0 metrics:nil views:views];
        [_metaScrollView addConstraints:horizontalConstraints];
        
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_metaContainerView]|" options:0 metrics:nil views:views];
        [_metaScrollView addConstraints:verticalConstraints];
    }
    
    // _infosView constraints
    {
        NSDictionary *views = NSDictionaryOfVariableBindings(_expandIcon, _nameLabel, _addressLabel, _distanceLabel, _providerLabel, _metaScrollView);
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_expandIcon][_nameLabel][_addressLabel]-(==7)-[_distanceLabel]-(==7)-[_providerLabel]-(==7)-[_metaScrollView]" options:0 metrics:nil views:views];
        [_infosView addConstraints:verticalConstraints];
        
        [self infosViewConstraints];
        
        for (UIView *view in views.allValues) {
            NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[view]-|" options:0 metrics:nil views:@{@"view" : view}];
            [_infosView addConstraints:horizontalConstraints];
        }
    }
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
    NSDictionary *views = NSDictionaryOfVariableBindings(_infosView, _tabBar);
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_infosView][_tabBar]|" options:0 metrics:nil views:views];
    [self addConstraints:verticalConstraints];
    
    for (UIView *view in views.allValues) {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
        [self addConstraints:horizontalConstraints];
    }
}

- (void)infosViewConstraints
{
    if (_bottomInfosViewContraint != nil)
        [_infosView removeConstraint:_bottomInfosViewContraint];
    
    if (_topInfosViewConstraint != nil)
        [self removeConstraint:_topInfosViewConstraint];
    
    if (_metaExpanded) {
        _bottomInfosViewContraint = [NSLayoutConstraint constraintWithItem:_metaScrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_infosView attribute:NSLayoutAttributeBottom multiplier:1 constant:-7];
        [_infosView addConstraint:_bottomInfosViewContraint];
        
        _topInfosViewConstraint = [NSLayoutConstraint constraintWithItem:_infosView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        [self addConstraint:_topInfosViewConstraint];
    } else {
        _bottomInfosViewContraint = [NSLayoutConstraint constraintWithItem:_distanceLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_infosView attribute:NSLayoutAttributeBottom multiplier:1 constant:-7];
        [_infosView addConstraint:_bottomInfosViewContraint];
    }
}

- (void)addMetas:(NSArray *)metas
{
    [_metaContainerView addMetas:metas];
}

- (void)updateMeta:(NSArray *)metas
{
    [_metaContainerView updateMetas:metas];
}

#pragma mark - UIGestureRecognizer methods

- (void)swipeGestureRecognizer:(UISwipeGestureRecognizer *)swipeGestureRecognizer
{
    if (swipeGestureRecognizer.state == UIGestureRecognizerStateRecognized) {

        BOOL newExpandedValue = swipeGestureRecognizer.direction == UISwipeGestureRecognizerDirectionUp;
        
        if (newExpandedValue == _metaExpanded)
            return;
        
        [self changeExpandedValue:newExpandedValue];
    }
}

- (void)tapGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (tapGestureRecognizer.state == UIGestureRecognizerStateRecognized) {
        CGPoint location = [tapGestureRecognizer locationInView:_infosView];

        if (location.y > 40)
            return;
        
        [self changeExpandedValue:!_metaExpanded];
    }
}

- (void)changeExpandedValue:(BOOL)metaExpanded
{
    _metaExpanded = metaExpanded;
    _expandIcon.image = [UIImage imageNamed:_metaExpanded ? @"reduce_icon" : @"expand_icon"];
    [self infosViewConstraints];
    [UIView animateWithDuration:0.2 animations:^{
        [self layoutIfNeeded];
    }];
}

#pragma mark - UITabBarDelegate methods

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    [_delegate launchRoute:[tabBar.items indexOfObject:item]];
}

#pragma mark - setter methods

- (void)setAddressInfos:(NSString *)name address:(NSString *)address provider:(NSString *)provider coordinates:(CLLocationCoordinate2D)coordinates
{
    _nameLabel.text = name;
    _addressLabel.text = address;
    _providerLabel.text = provider;
    
    [_marker setPosition:coordinates];
    _marker.snippet = address;
    _marker.title = name;
    
    GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithTarget:coordinates zoom:14];
    _mapView.camera = cameraPosition;
}

- (void)setDistance:(double)distance
{
    NSString *color = @"#6b6b6b";
    NSString *iconName = @"gmap_pin_neutral";
    if (distance > 0) {
        NSArray *distanceColors = kCCLinotteColors;
        int distanceColorIndex = distance / 500;
        distanceColorIndex = MIN(distanceColorIndex, (int)[distanceColors count] - 1);
        color = distanceColors[distanceColorIndex];
        
        iconName = [NSString stringWithFormat:@"gmap_pin_%@", [color substringFromIndex:1]];
        _currentColor = color;
        
        NSString *distanceUnit = distance > 1000 ? @"km" : @"m";
        double displayDistance = distance > 1000 ? distance / 1000 : distance;
        NSString *distanceString = [NSString stringWithFormat:@"%.02f %@", displayDistance, distanceUnit];
        _distanceLabel.text = distanceString;
    }
    
    _marker.icon = [UIImage imageNamed:iconName];
}

@end
