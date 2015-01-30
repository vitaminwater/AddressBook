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

#import "CCFlatColorButton.h"

#import "CCMetaContainerView.h"
#import "CCActionButtonsView.h"

#import "CCNoteView.h"

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
    CCMetaContainerView *_displayMetaContainerView;
    UITabBar *_tabBar;
    
    NSLayoutConstraint *_topInfosViewConstraint;
    NSLayoutConstraint *_bottomInfosViewContraint;
    
    CCActionButtonsView *_actionButtonsView;
    CCNoteView *_noteView;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.opaque = YES;
        _metaExpanded = NO;
        
        /*{
            UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureRecognizer:)];
            swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
            swipeGestureRecognizer.delegate = self;
            [self addGestureRecognizer:swipeGestureRecognizer];
        }
        
        {
            UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureRecognizer:)];
            swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
            swipeGestureRecognizer.delegate = self;
            [self addGestureRecognizer:swipeGestureRecognizer];
        }*/

        [self setupMap];
        [self setupActionsButtonView];
        [self setupInfoView];
        [self setupButtons];
        [self setupLayout];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupMap
{
    _mapView = [GMSMapView new];
    _mapView.myLocationEnabled = YES;
    _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _mapView.frame = self.bounds;
    _mapView.delegate = self;
    [self addSubview:_mapView];
    
    _marker = [[GMSMarker alloc] init];
    _marker.icon = [UIImage imageNamed:@"gmap_pin_neutral"];;
    _marker.map = _mapView;
}

- (void)setupActionsButtonView
{
    _actionButtonsView = [[CCActionButtonsView alloc] initWithActionViewParent:self];
    _actionButtonsView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_actionButtonsView];
    
    _noteView = [CCNoteView new];
    _noteView.delegate = self;
    [_actionButtonsView addActionWithView:_noteView fullWidth:YES minHeight:200 icon:[UIImage imageNamed:@"note_icon"]];
    [_actionButtonsView setupLayout];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_actionButtonsView);
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[_actionButtonsView(==60)]-(==5)-|" options:0 metrics:nil views:views];
    [self addConstraints:horizontalConstraints];

    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==5)-[_actionButtonsView]" options:0 metrics:nil views:views];
    [self addConstraints:verticalConstraints];
}

- (void)setupInfoView
{
    _infosView = [UIView new];
    _infosView.translatesAutoresizingMaskIntoConstraints = NO;
    _infosView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
    [self addSubview:_infosView];
    
    {
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)];
        tapGestureRecognizer.delegate = self;
        [_infosView addGestureRecognizer:tapGestureRecognizer];
    }
    
    _expandIcon = [UIImageView new];
    _expandIcon.translatesAutoresizingMaskIntoConstraints = NO;
    [_expandIcon setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    _expandIcon.image = [UIImage imageNamed:@"expand_icon"];
    _expandIcon.backgroundColor = [UIColor clearColor];
    _expandIcon.contentMode = UIViewContentModeCenter;
    _expandIcon.hidden = YES;
    [_infosView addSubview:_expandIcon];
    
    _nameLabel = [UILabel new];
    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_nameLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    _nameLabel.textColor = [UIColor darkGrayColor];
    _nameLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:18];
    _nameLabel.numberOfLines = 0;
    [_infosView addSubview:_nameLabel];
    
    _addressLabel = [UILabel new];
    _addressLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_addressLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    _addressLabel.textColor = [UIColor darkGrayColor];
    _addressLabel.font = [UIFont fontWithName:@"Futura-Book" size:15];
    _addressLabel.numberOfLines = 0;
    [_infosView addSubview:_addressLabel];
    
    _distanceLabel = [UILabel new];
    _distanceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_distanceLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    _distanceLabel.textColor = [UIColor darkGrayColor];
    _distanceLabel.font = [UIFont fontWithName:@"Futura-Book" size:16];
    _distanceLabel.text = NSLocalizedString(@"DISTANCE_UNAVAILABLE", @"");
    [_infosView addSubview:_distanceLabel];
    
    _providerLabel = [UILabel new];
    _providerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_providerLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    _providerLabel.textColor = [UIColor darkGrayColor];
    _providerLabel.font = [UIFont fontWithName:@"Futura-Book" size:15];
    _providerLabel.numberOfLines = 0;
    [_infosView addSubview:_providerLabel];
    
    _metaScrollView = [UIScrollView new];
    _metaScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [_infosView addSubview:_metaScrollView];
    
    _displayMetaContainerView = [CCMetaContainerView new];
    _displayMetaContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [_metaScrollView addSubview:_displayMetaContainerView];
    
    // _metaContainerView constraints
    {
        NSDictionary *views = NSDictionaryOfVariableBindings(_displayMetaContainerView, _metaScrollView);
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_displayMetaContainerView(==_metaScrollView)]|" options:0 metrics:nil views:views];
        [_metaScrollView addConstraints:horizontalConstraints];
        
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_displayMetaContainerView]|" options:0 metrics:nil views:views];
        [_metaScrollView addConstraints:verticalConstraints];
    }
    
    // _infosView constraints
    {
        NSDictionary *views = NSDictionaryOfVariableBindings(_expandIcon, _nameLabel, _addressLabel, _distanceLabel, _providerLabel, _metaScrollView);
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_expandIcon][_nameLabel][_addressLabel]-(==7)-[_distanceLabel]-(==7)-[_providerLabel]-(==7)-[_metaScrollView]-(==25)-|" options:0 metrics:nil views:views];
        [_infosView addConstraints:verticalConstraints];
        
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
    
    NSArray *tabBarBottomConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_tabBar]|" options:0 metrics:nil views:views];
    [self addConstraints:tabBarBottomConstraints];
    
    NSLayoutConstraint *infosViewHeightConstraint = [NSLayoutConstraint constraintWithItem:_infosView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    [self addConstraint:infosViewHeightConstraint];

    [self infosViewConstraints];

    for (UIView *view in views.allValues) {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
        [self addConstraints:horizontalConstraints];
    }
}

- (void)infosViewConstraints
{
    if (_bottomInfosViewContraint != nil)
        [self removeConstraint:_bottomInfosViewContraint];
    
    if (_topInfosViewConstraint != nil)
        [self removeConstraint:_topInfosViewConstraint];
    
    if (_metaExpanded) {
        _topInfosViewConstraint = [NSLayoutConstraint constraintWithItem:_infosView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        [self addConstraint:_topInfosViewConstraint];
    } else {
        _bottomInfosViewContraint = [NSLayoutConstraint constraintWithItem:_distanceLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_tabBar attribute:NSLayoutAttributeTop multiplier:1 constant:-7];
        [self addConstraint:_bottomInfosViewContraint];
    }
}

- (void)setDisplayMetas:(NSArray *)metas
{
    if ([metas count] == 0)
        return;
    [_displayMetaContainerView addMetas:metas];
    _expandIcon.hidden = NO;
}

- (void)setSocialMetas:(NSArray *)metas
{
    if ([metas count] == 0)
        return;
    CCMetaContainerView *metaContainerView = [CCMetaContainerView new];
    [metaContainerView addMetas:metas];
    [_actionButtonsView addActionWithView:metaContainerView fullWidth:NO minHeight:0 icon:[UIImage imageNamed:@"social_icon"]];
    [_actionButtonsView setupLayout];
}

- (void)setExternalMetas:(NSArray *)metas
{
    if ([metas count] == 0)
        return;
    CCMetaContainerView *metaContainerView = [CCMetaContainerView new];
    metas = [metas sortedArrayUsingComparator:^NSComparisonResult(id<CCMetaProtocol> obj1, id<CCMetaProtocol> obj2) {
        if (obj1.content[@"title"] != nil && obj2.content[@"title"] == nil)
            return NSOrderedDescending;
        else if (obj2.content[@"title"] != nil && obj1.content[@"title"] == nil)
            return NSOrderedAscending;
        return NSOrderedSame;
    }];
    [metaContainerView addMetas:metas];
    [_actionButtonsView addActionWithView:metaContainerView fullWidth:NO minHeight:0 icon:[UIImage imageNamed:@"cloud_icon"]];
    [_actionButtonsView setupLayout];
}

- (void)setHoursMetas:(NSArray *)metas
{
    if ([metas count] == 0)
        return;
    CCMetaContainerView *metaContainerView = [CCMetaContainerView new];
    [metaContainerView addMetas:metas];
    [_actionButtonsView addActionWithView:metaContainerView fullWidth:NO minHeight:0 icon:[UIImage imageNamed:@"clock_icon"]];
    [_actionButtonsView setupLayout];
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
    if (_expandIcon.hidden == YES)
        return;
    if (tapGestureRecognizer.state == UIGestureRecognizerStateRecognized) {
        CGPoint location = [tapGestureRecognizer locationInView:_infosView];

        if (location.y > 40)
            return;
        [_actionButtonsView removeActionView];
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

#pragma mark - UITextView delegate methods

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [_delegate setAddressNote:textView.text];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint pos = [gestureRecognizer locationInView:_tabBar];
    if (CGRectContainsPoint(_tabBar.bounds, pos))
        return NO;
    return YES;
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
    _mapView.selectedMarker = _marker;
    
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

- (void)setDelegate:(id<CCOutputViewDelegate>)delegate
{
    _delegate = delegate;
    _noteView.text = [_delegate addressNote];
}

#pragma mark - GMSMapViewDelegate methods

/*- (UIView *)mapView:(GMSMapView *)mapView markerInfoContents:(GMSMarker *)marker
{
    UILabel *label = [UILabel new];
    label.text = @"pouet pout pwoeutproe";
    label.textColor = [UIColor blackColor];
    [label sizeThatFits:CGSizeMake(500, CGFLOAT_MAX)];
    return label;
}*/

@end
