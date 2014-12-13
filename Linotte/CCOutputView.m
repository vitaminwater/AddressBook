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
    
    CCFlatColorButton *_noteButton;
    UIView *_noteView;
    UITextView *_noteField;
    NSLayoutConstraint *_noteViewYConstraint;
    NSLayoutConstraint *_noteViewHeightConstraint;
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
            swipeGestureRecognizer.delegate = self;
            [self addGestureRecognizer:swipeGestureRecognizer];
        }
        
        {
            UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureRecognizer:)];
            swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
            swipeGestureRecognizer.delegate = self;
            [self addGestureRecognizer:swipeGestureRecognizer];
        }
        
        {
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)];
            tapGestureRecognizer.delegate = self;
            [self addGestureRecognizer:tapGestureRecognizer];
        }

        [self setupMap];
        [self setupNoteButton];
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
    [self addSubview:_mapView];
    
    _marker = [[GMSMarker alloc] init];
    _marker.icon = [UIImage imageNamed:@"gmap_pin_neutral"];;
    _marker.map = _mapView;
}

- (void)setupNoteButton
{
    _noteButton = [CCFlatColorButton new];
    _noteButton.translatesAutoresizingMaskIntoConstraints = NO;
    _noteButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [_noteButton setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.7] forState:UIControlStateHighlighted];
    [_noteButton setImage:[UIImage imageNamed:@"note_icon"] forState:UIControlStateNormal];
    [_noteButton addTarget:self action:@selector(noteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _noteButton.layer.cornerRadius = 4;
    [self addSubview:_noteButton];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_noteButton);
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[_noteButton]-(==5)-|" options:0 metrics:nil views:views];
    [self addConstraints:horizontalConstraints];

    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==5)-[_noteButton]" options:0 metrics:nil views:views];
    [self addConstraints:verticalConstraints];
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

- (void)showNoteView
{
    if (_noteView != nil)
        return;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];

    _noteView = [UIView new];
    _noteView.translatesAutoresizingMaskIntoConstraints = NO;
    _noteView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [self addSubview:_noteView];
    
    _noteField = [UITextView new];
    _noteField.translatesAutoresizingMaskIntoConstraints = NO;
    _noteField.backgroundColor = [UIColor clearColor];
    _noteField.textColor = [UIColor whiteColor];
    _noteField.font = [UIFont fontWithName:@"Futura-Book" size:21];
    _noteField.text = [_delegate addressNote];
    [_noteField setTintColor:[UIColor whiteColor]];
    _noteField.delegate = self;
    [_noteView addSubview:_noteField];
    
    CCFlatColorButton *closeButton = [CCFlatColorButton new];
    closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    closeButton.titleLabel.font = [UIFont fontWithName:@"Futura-Book" size:23];
    [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    closeButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
    [closeButton setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.3] forState:UIControlStateHighlighted];
    [closeButton addTarget:self action:@selector(closeNoteViewButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [closeButton setTitle:NSLocalizedString(@"CLOSE", @"") forState:UIControlStateNormal];
    [_noteView addSubview:closeButton];
    
    {
        NSDictionary *views = NSDictionaryOfVariableBindings(_noteField, closeButton);
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_noteField][closeButton(==40)]|" options:0 metrics:nil views:views];
        [_noteView addConstraints:verticalConstraints];
        
        for (UIView *view in views.allValues) {
            NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:view == _noteField ? @"H:|-[view]-|" : @"H:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
            [_noteView addConstraints:horizontalConstraints];
        }
    }
    
    {
        NSDictionary *views = NSDictionaryOfVariableBindings(_noteView);
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_noteView]|" options:0 metrics:nil views:views];
        [self addConstraints:horizontalConstraints];
        
        _noteViewHeightConstraint = [NSLayoutConstraint constraintWithItem:_noteView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
        [self addConstraint:_noteViewHeightConstraint];
        
        NSLayoutConstraint *yConstraint = [NSLayoutConstraint constraintWithItem:_noteView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        [self addConstraint:yConstraint];
        
        [self layoutIfNeeded];
        
        [UIView animateWithDuration:0.2 animations:^{
            [self removeConstraint:yConstraint];
            
            _noteButton.alpha = 0;
            
            _noteViewYConstraint = [NSLayoutConstraint constraintWithItem:_noteView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
            [self addConstraint:_noteViewYConstraint];
            [self layoutIfNeeded];
        }];
    }
    
    if ([_noteField.text isEqualToString:@""])
        [_noteField becomeFirstResponder];
}

- (void)removeNoteView
{
    [self removeConstraint:_noteViewYConstraint];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [UIView animateWithDuration:0.2 animations:^{
        NSLayoutConstraint *yConstraint = [NSLayoutConstraint constraintWithItem:_noteView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        [self addConstraint:yConstraint];
        
        _noteButton.alpha = 1;
        
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [_noteView removeFromSuperview];
        _noteView = nil;
    }];
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

#pragma mark - UIButton target methods

- (void)noteButtonPressed:(UIButton *)sender
{
    [self showNoteView];
}

- (void)closeNoteViewButtonPressed:(UIButton *)sender
{
    [self removeNoteView];
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

#pragma mark - UITextView delegate methods

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [_delegate setAddressNote:textView.text];
}

#pragma mark - NSNotificationCenter target methods

- (void)keyboardWillShowNotification:(NSNotification *)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameEnd = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameEndRect = [keyboardFrameEnd CGRectValue];
    
    _noteViewHeightConstraint.constant = -keyboardFrameEndRect.size.height;
    
    [UIView animateWithDuration:0.2 animations:^{
        [self layoutIfNeeded];
    }];
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
