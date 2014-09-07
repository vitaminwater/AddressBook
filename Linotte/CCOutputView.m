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

#import "CCOutputConfirmEntryView.h"
#import "CCSettingsView.h"
#import "CCListSettingsView.h"

@interface CCOutputView()

@property(nonatomic, strong)GMSMarker *marker;
@property(nonatomic, strong)GMSMapView *mapView;
@property(nonatomic, strong)CCSettingsView *addressSettingsView;
@property(nonatomic, strong)CCListSettingsView *listSettingsView;
@property(nonatomic, strong)UITextView *infoView;

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
    
    UITabBarItem *trainItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"ROUTE_TRAIN", @"") image:[UIImage imageNamed:@"train.png"] selectedImage:nil];
    UITabBarItem *carItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"ROUTE_CAR", @"") image:[UIImage imageNamed:@"car.png"] selectedImage:nil];
    UITabBarItem *bicycleItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"ROUTE_BICYCLE", @"") image:[UIImage imageNamed:@"bicycle.png"] selectedImage:nil];
    UITabBarItem *walkItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"ROUTE_WALK", @"") image:[UIImage imageNamed:@"walk.png"] selectedImage:nil];
    
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
    NSString *iconName = @"neutral_marker";
    if (addressDistance > 0) {
        NSArray *distanceColors = kCCLinotteColors;
        int distanceColorIndex = addressDistance / 500;
        distanceColorIndex = MIN(distanceColorIndex, (int)[distanceColors count] - 1);
        color = distanceColors[distanceColorIndex];
        iconName = [NSString stringWithFormat:@"gmap_pin_%@.png", [color substringFromIndex:1]];
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

#pragma mark - Public methods

- (void)showIsNewMessage
{
    CCOutputConfirmEntryView *confirmEntryView = [CCOutputConfirmEntryView new];
    confirmEntryView.translatesAutoresizingMaskIntoConstraints = NO;
    confirmEntryView.delegate = self;
    [self addSubview:confirmEntryView];
    
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:confirmEntryView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    [self addConstraint:centerXConstraint];
    
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:confirmEntryView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    [self addConstraint:centerYConstraint];
    
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:confirmEntryView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    [self addConstraint:widthConstraint];
    
    confirmEntryView.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{
        confirmEntryView.alpha = 1;
    }];
}

- (void)showSettingsView
{
    if (_addressSettingsView)
        return;
    
    _addressSettingsView = [CCSettingsView new];
    _addressSettingsView.translatesAutoresizingMaskIntoConstraints = NO;
    _addressSettingsView.delegate = self;
    _addressSettingsView.notificationEnabled = [_delegate notificationEnabled];
    _addressSettingsView.listName = [_delegate currentListNames];
    [self addSubview:_addressSettingsView];
    
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:_addressSettingsView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    [self addConstraint:centerXConstraint];
    
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:_addressSettingsView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    [self addConstraint:centerYConstraint];
    
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:_addressSettingsView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:-20];
    [self addConstraint:widthConstraint];
    
    _addressSettingsView.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{
        _addressSettingsView.alpha = 1;
    }];
}

- (void)closeSettingsView
{
    if (_addressSettingsView == nil)
        return;
    [UIView animateWithDuration:0.2 animations:^{
        _addressSettingsView.alpha = 0;
    } completion:^(BOOL finished) {
        [_addressSettingsView removeFromSuperview];
        _addressSettingsView = nil;
    }];
}

#pragma mark - CCOutputConfirmEntryViewDelegate methods

- (void)closeConfirmView:(id)sender
{
    CCOutputConfirmEntryView *confirmEntryView = sender;
    
    [_delegate setNotificationEnabled:confirmEntryView.notificationEnabled];
    
    [UIView animateWithDuration:0.2 animations:^{
        confirmEntryView.alpha = 0;
    } completion:^(BOOL finished) {
        [confirmEntryView removeFromSuperview];
    }];
}

#pragma mark - CCSettingsViewDelegate methods

- (void)closeButtonPressed:(CCSettingsView *)sender
{
    [self closeSettingsView];
}

- (void)setNotificationEnabled:(BOOL)enabled
{
    [_delegate setNotificationEnabled:enabled];
}

- (void)showListSetting
{
    if (_listSettingsView)
        return;
    
    _listSettingsView = [CCListSettingsView new];
    _listSettingsView.translatesAutoresizingMaskIntoConstraints = NO;
    _listSettingsView.delegate = self;
    [self addSubview:_listSettingsView];
    
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:_listSettingsView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    [self addConstraint:centerXConstraint];
    
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:_listSettingsView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    [self addConstraint:centerYConstraint];
    
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:_listSettingsView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:-20];
    [self addConstraint:widthConstraint];
    
    _listSettingsView.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{
        _listSettingsView.alpha = 1;
    }];
}

#pragma mark - CCListSettingsViewDelegate

- (void)closeListSettingsView:(id)sender success:(BOOL)success
{
    if (success) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
        
        UIImageView *completedImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"completed"]];
        hud.customView = completedImage;
        //hud.detailsLabelText = [NSString localizedStringByReplacingFromDictionnary:@{@"[listName]" : [_delegate addressName]} localizedKey:@"MOVED_TO"];
        
        hud.mode = MBProgressHUDModeCustomView;
        hud.opacity = 0.4;
        
        [hud show:YES];
        [hud hide:YES afterDelay:1];
    }
    [UIView animateWithDuration:0.2 animations:^{
        _listSettingsView.alpha = 0;
    } completion:^(BOOL finished) {
        [_listSettingsView removeFromSuperview];
        _listSettingsView = nil;
    }];
}

- (NSString *)addressName
{
    return [_delegate addressName];
}

- (NSUInteger)numberOfLists
{
    return [_delegate numberOfLists];
}

- (NSString *)listNameAtIndex:(NSUInteger)index
{
    return [_delegate listNameAtIndex:index];
}

- (NSString *)listIconAtIndex:(NSUInteger)index
{
    return [_delegate listIconAtIndex:index];
}

- (void)listSelectedAtIndex:(NSUInteger)index
{
    [_delegate listSelectedAtIndex:index];
    _addressSettingsView.listName = [_delegate currentListNames];
}

- (void)listUnselectedAtIndex:(NSUInteger)index
{
    [_delegate listUnselectedAtIndex:index];
    _addressSettingsView.listName = [_delegate currentListNames];
}

- (NSUInteger)createListWithName:(NSString *)name
{
    NSUInteger insertIndex = [_delegate createListWithName:name];
    _addressSettingsView.listName = [_delegate currentListNames];
    return insertIndex;
}

- (BOOL)isListSelectedAtIndex:(NSUInteger)index
{
    return [_delegate isListSelectedAtIndex:index];
}

#pragma mark - UITabBarDelegate methods

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    [_delegate launchRoute:[tabBar.items indexOfObject:item]];
}

@end
