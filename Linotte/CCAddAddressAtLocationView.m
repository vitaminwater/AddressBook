//
//  CCAddAddressAtLocationView.m
//  Linotte
//
//  Created by stant on 26/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCAddAddressAtLocationView.h"

#import <GoogleMaps/GoogleMaps.h>

@implementation CCAddAddressAtLocationView
{
    UITextField *_nameField;
    
    GMSMapView *_mapView;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self setupNameField];
        [self setupMapView];
        [self setupLayout];
    }
    return self;
}

- (void)setupNameField
{
    _nameField = [UITextField new];
    _nameField.translatesAutoresizingMaskIntoConstraints = NO;
    _nameField.font = [UIFont fontWithName:@"Montserrat-Bold" size:28];
    _nameField.textColor = [UIColor darkGrayColor];
    _nameField.backgroundColor = [UIColor whiteColor];
    _nameField.placeholder = NSLocalizedString(@"PLACE_NAME", @"");
    
    UIImageView *leftView = [UIImageView new];
    leftView.frame = CGRectMake(0, 0, 58, [kCCAddViewTextFieldHeight floatValue]);
    leftView.contentMode = UIViewContentModeCenter;
    leftView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    leftView.image = [UIImage imageNamed:@"add_field_icon"];
    _nameField.leftView = leftView;
    _nameField.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *rightView = [UIView new];
    rightView.frame = CGRectMake(0, 0, 15, [kCCAddViewTextFieldHeight floatValue]);
    rightView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _nameField.rightView = rightView;
    _nameField.rightViewMode = UITextFieldViewModeAlways;
    
    [self addSubview:_nameField];
}

- (void)setupMapView
{
    _mapView = [GMSMapView new];
    _mapView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_mapView];
}

- (void)setupLayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_nameField, _mapView);
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_nameField(==kCCAddViewTextFieldHeight)][_mapView]|" options:0 metrics:kCCAddViewTextFieldHeightMetric views:views];
    [self addConstraints:verticalConstraints];
    
    for (UIView *view in views.allValues) {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
        [self addConstraints:horizontalConstraints];
    }
}

- (void)setFirstInputAsFirstResponder
{
    [_nameField becomeFirstResponder];
}

@end
