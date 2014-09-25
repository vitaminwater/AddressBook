//
//  CCOutputViewController.h
//  Linotte
//
//  Created by stant on 12/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>

#import "CCOutputViewControllerDelegate.h"

#import "CCAddressSettingsViewControllerDelegate.h"
#import "CCAddressListSettingsViewControllerDelegate.h"
#import "CCFirstAddressDisplaySettingsViewController.h"

#import "CCOutputViewDelegate.h"

@class CCAddress;

@interface CCOutputViewController : UIViewController<CCOutputViewDelegate, CCFirstAddressDisplaySettingsViewControllerDelegate, CCAddressSettingsViewControllerDelegate, CCAddressListSettingsViewControllerDelegate, CLLocationManagerDelegate>

@property(nonatomic, assign)id<CCOutputViewControllerDelegate> delegate;

- (id)initWithAddress:(CCAddress *)address addressIsNew:(BOOL)addressIsNew;
- (id)initWithAddress:(CCAddress *)address;

@end
