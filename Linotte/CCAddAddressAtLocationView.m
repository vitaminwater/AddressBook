//
//  CCAddAddressAtLocationView.m
//  Linotte
//
//  Created by stant on 26/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCAddAddressAtLocationView.h"

#import <HexColors/HexColor.h>

#import "CCAlertView.h"
#import "CCLinotteField.h"
#import "CCFlatColorButton.h"

#import "CCAddAddressTabButtons.h"

#define kCCAddAddressViewMetrics @{@"kCCAddTextFieldHeight" : kCCLinotteTextFieldHeight, @"kCCButtonViewHeight" : kCCButtonViewHeight}

@implementation CCAddAddressAtLocationView
{
    UITextField *_nameField;
    
    CCAddAddressTabButtons *_tabButtons;
    
    GMSMapView *_mapView;
    GMSMarker *_positionMarker;
    BOOL _mapMoved;
    
    UIButton *_backToCurrentLocationButton;
    
    CCFlatColorButton *_validateButton;
}

@dynamic nameFieldValue;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.opaque = YES;
        _mapMoved = NO;
        
        [self setupNameField];
        [self setupTabButtons];
        [self setupMapView];
        [self setupBackToCurrentLocationButton];
        [self setupValidateButton];
        [self setupLayout];
    }
    return self;
}

- (void)setupNameField
{
    _nameField = [[CCLinotteField alloc] initWithImage:[UIImage imageNamed:@"add_field_icon"]];
    _nameField.translatesAutoresizingMaskIntoConstraints = NO;
    _nameField.placeholder = NSLocalizedString(@"PLACE_NAME", @"");
    _nameField.delegate = self;
    [self addSubview:_nameField];
}

- (void)setupTabButtons
{
    _tabButtons = [CCAddAddressTabButtons new];
    _tabButtons.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_tabButtons];
}

- (void)setupMapView
{
    _mapView = [GMSMapView new];
    _mapView.translatesAutoresizingMaskIntoConstraints = NO;
    _mapView.myLocationEnabled = YES;
    _mapView.delegate = self;
    [self addSubview:_mapView];
    
    _positionMarker = [GMSMarker markerWithPosition:_mapView.camera.target];
    _positionMarker.icon = [UIImage imageNamed:@"gmap_pin_neutral"];
    [_positionMarker setDraggable:NO];
    [_positionMarker setTappable:NO];
    _positionMarker.map = _mapView;

    [_mapView animateToZoom:kGMSMinZoomLevel];
}

- (void)setupBackToCurrentLocationButton
{
    _backToCurrentLocationButton = [UIButton new];
    _backToCurrentLocationButton.translatesAutoresizingMaskIntoConstraints = NO;
    _backToCurrentLocationButton.hidden = YES;
    _backToCurrentLocationButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    _backToCurrentLocationButton.layer.cornerRadius = 3;
    [_backToCurrentLocationButton setBackgroundImage:[UIImage imageNamed:@"location_arrow"] forState:UIControlStateNormal];
    _backToCurrentLocationButton.contentMode = UIViewContentModeCenter;
    
    [_backToCurrentLocationButton addTarget:self action:@selector(backToCurrentLocationButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_backToCurrentLocationButton];
}

- (void)setupValidateButton
{
    _validateButton = [CCFlatColorButton new];
    _validateButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_validateButton setTitle:NSLocalizedString(@"OK", @"") forState:UIControlStateNormal];
    //_validateButton.layer.cornerRadius = 10;
    _validateButton.clipsToBounds = YES;
    
    [_validateButton addTarget:self action:@selector(validateButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _validateButton.backgroundColor = [UIColor colorWithHexString:@"#5acfc4"];
    [_validateButton setBackgroundColor:[UIColor colorWithHexString:@"#4abfb4"] forState:UIControlStateHighlighted];
    [self addSubview:_validateButton];
}

- (void)setupLayout
{
    {
        NSDictionary *views = NSDictionaryOfVariableBindings(_nameField, _tabButtons, _mapView);
        
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_nameField(kCCAddTextFieldHeight)][_tabButtons(kCCButtonViewHeight)][_mapView]|" options:0 metrics:kCCAddAddressViewMetrics views:views];
        [self addConstraints:verticalConstraints];
        
        for (UIView *view in views.allValues) {
            NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
            [self addConstraints:horizontalConstraints];
        }
    }
    
    // back to current location button constraints
    {
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:_backToCurrentLocationButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_mapView attribute:NSLayoutAttributeTop multiplier:1 constant:5];
        [self addConstraint:topConstraint];
        
        NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:_backToCurrentLocationButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_mapView attribute:NSLayoutAttributeRight multiplier:1 constant:-5];
        [self addConstraint:rightConstraint];
    }
    
    // buttons constraints
    {
        NSDictionary *views = NSDictionaryOfVariableBindings(_validateButton);
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_validateButton]|" options:0 metrics:nil views:views];
        [self addConstraints:horizontalConstraints];
        
        {
            NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:_validateButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_mapView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
            [self addConstraint:bottomConstraint];
        }
    }
}

- (void)setFirstInputAsFirstResponder
{
    [_nameField becomeFirstResponder];
}

- (void)cleanBeforeClose
{
    [_nameField resignFirstResponder];
    _nameField.text = @"";
}

- (void)resetTabButtonPosition
{
    [_tabButtons setSelectedTabButton:CCAddAddressAtLocationType];
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - GMSMapViewDelegate methods

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position
{
    _mapMoved = YES;
    _positionMarker.position = position.target;
    [_nameField resignFirstResponder];
}

#pragma mark - UIButton target methods

- (void)backToCurrentLocationButtonPressed:(id)sender
{
    [_mapView animateToLocation:_currentLocation];
}

- (void)validateButtonPressed:(id)sender
{
    if ([_nameField.text length] == 0) {
        [CCAlertView showAlertViewWithText:NSLocalizedString(@"ADDRESS_NAME_MISSING", @"") target:self leftAction:@selector(missingNameAlertViewLeftAction:) rightAction:@selector(missingNameAlertViewRightAction:)];
        return;
    }
    [_delegate validateButtonPressed];
    [self cleanBeforeClose];
}

#pragma mark - CCAlertView target methods

- (void)missingNameAlertViewLeftAction:(id)sender
{
    [CCAlertView closeAlertView:sender];
    [_nameField becomeFirstResponder];
}

- (void)missingNameAlertViewRightAction:(id)sender
{
    [CCAlertView closeAlertView:sender];
    [_nameField resignFirstResponder];
}

#pragma mark - setter methods

- (void)setCurrentLocation:(CLLocationCoordinate2D)currentLocation
{
    _currentLocation = currentLocation;
    if (_mapMoved == NO) {
        _positionMarker.position = _currentLocation;
        [_mapView animateToLocation:_currentLocation];
        [_mapView animateToZoom:16];
    }
    _backToCurrentLocationButton.hidden = NO;
}

- (void)setNameFieldValue:(NSString *)nameFieldValue
{
    _nameField.text = nameFieldValue;
}

- (void)setDelegate:(id<CCAddAddressAtLocationViewDelegate>)delegate
{
    _delegate = delegate;
    _tabButtons.delegate = delegate;
}

#pragma mark - getter methods

- (NSString *)nameFieldValue
{
    return _nameField.text;
}

- (CLLocationCoordinate2D)addressCoordinates
{
    return _positionMarker.position;
}

@end
