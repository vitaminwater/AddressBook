//
//  CCOutputView.h
//  Linotte
//
//  Created by stant on 12/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>

#import "CCOutputViewDelegate.h"

#import "CCMetaProtocol.h"

@interface CCOutputView : UIView<UITabBarDelegate, UITextViewDelegate, UIGestureRecognizerDelegate, GMSMapViewDelegate>

@property(nonatomic, readonly)NSString *currentColor;

@property(nonatomic, weak)id <CCOutputViewDelegate>delegate;

- (void)setDisplayMetas:(NSArray *)metas;
- (void)setSocialMetas:(NSArray *)metas;
- (void)setExternalMetas:(NSArray *)metas;
- (void)setHoursMetas:(NSArray *)metas;
- (void)setAddressInfos:(NSString *)name address:(NSString *)address provider:(NSString *)provider coordinates:(CLLocationCoordinate2D)coordinates;
- (void)setDistance:(double)distance;

@end
