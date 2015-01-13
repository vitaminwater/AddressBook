//
//  CCBaseListStoreViewController.h
//  Linotte
//
//  Created by stant on 04/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>

#import "CCListInstallerViewControllerDelegate.h"

@class CCBaseListStoreView;

@interface CCBaseListStoreViewController : UIViewController<CCListInstallerViewControllerDelegate, CLLocationManagerDelegate>

@property(nonatomic, assign)CLLocation *location;
@property(nonatomic, readonly)CCBaseListStoreView *listStoreView;

- (void)showListInstaller:(NSString *)identifier;

@end
