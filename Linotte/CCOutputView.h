//
//  CCOutputView.h
//  Linotte
//
//  Created by stant on 12/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>

#import "CCOutputViewDelegate.h"

#import "CCMetaProtocol.h"

@interface CCOutputView : UIView<UITabBarDelegate>

@property(nonatomic, readonly)NSString *currentColor;

@property(nonatomic, weak)id <CCOutputViewDelegate>delegate;

- (void)addMetas:(NSArray *)metas;
- (void)updateMeta:(NSArray *)metas;
- (void)setAddressInfos:(NSString *)name address:(NSString *)address provider:(NSString *)provider coordinates:(CLLocationCoordinate2D)coordinates;
- (void)setDistance:(double)distance;

@end
