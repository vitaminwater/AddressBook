//
//  CCAddAddressAtLocationView.h
//  Linotte
//
//  Created by stant on 26/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <GoogleMaps/GoogleMaps.h>

#import "CCAddAddressAtLocationViewDelegate.h"

@interface CCAddAddressAtLocationView : UIView<UITextFieldDelegate, GMSMapViewDelegate>

@property(nonatomic, weak)id<CCAddAddressAtLocationViewDelegate> delegate;
@property(nonatomic, strong)NSString *nameFieldValue;
@property(nonatomic, readonly)CLLocationCoordinate2D addressCoordinates;

@property(nonatomic, assign)CLLocationCoordinate2D currentLocation;

- (void)setFirstInputAsFirstResponder;
- (void)cleanBeforeClose;

@end
