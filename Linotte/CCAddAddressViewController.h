//
//  CCAddViewController.h
//  Linotte
//
//  Created by stant on 06/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>

#import "CCAddAddressViewDelegate.h"

#import "CCAddAddressViewControllerDelegate.h"

@interface CCAddAddressViewController : UIViewController<CCAddAddressViewDelegate, CLLocationManagerDelegate>

@property(nonatomic, weak)id<CCAddAddressViewControllerDelegate> delegate;

@end
