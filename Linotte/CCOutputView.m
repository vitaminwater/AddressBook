//
//  CCOutputView.m
//  Linotte
//
//  Created by stant on 12/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCOutputView.h"

#import <GoogleMaps/GoogleMaps.h>

@interface CCOutputView()
{
    UITextView *_infoView;
}

@property(nonatomic, strong)GMSMapView *mapView;

@end

@implementation CCOutputView

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
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = camera.target;
    marker.snippet = [_delegate addressName];
    marker.title = [_delegate addressName];
    marker.map = mapView;
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
    
    UITabBarItem *trainItem = [[UITabBarItem alloc] initWithTitle:@"Train" image:[UIImage imageNamed:@"train.png"] selectedImage:nil];
    UITabBarItem *carItem = [[UITabBarItem alloc] initWithTitle:@"Car" image:[UIImage imageNamed:@"car.png"] selectedImage:nil];
    UITabBarItem *bicycleItem = [[UITabBarItem alloc] initWithTitle:@"Bicycle" image:[UIImage imageNamed:@"bicycle.png"] selectedImage:nil];
    UITabBarItem *walkItem = [[UITabBarItem alloc] initWithTitle:@"Walk" image:[UIImage imageNamed:@"walk.png"] selectedImage:nil];
    
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
    UIFont *titleFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
    NSString *string = [NSString stringWithFormat:@"%@\n%@\n%.02f m", addressName, addressString, addressDistance];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedText setAttributes:@{NSFontAttributeName: titleFont} range:NSMakeRange(0, [addressName length])];
    
    [_infoView setAttributedText:attributedText];
}

#pragma mark - UITabBarDelegate methods

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSArray *directionsMode = @[@"transit", @"driving", @"bicycling", @"walking"];
    NSString *url = [NSString stringWithFormat:@"comgooglemaps://?daddr=%f,%f&directionsmode=%@", [_delegate addressLatitude], [_delegate addressLongitude], directionsMode[[tabBar.items indexOfObject:item]]];
    if ([[UIApplication sharedApplication] canOpenURL:
          [NSURL URLWithString:url]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}

@end
