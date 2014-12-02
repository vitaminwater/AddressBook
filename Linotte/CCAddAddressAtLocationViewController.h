//
//  CCAddAddressAtLocationViewController.h
//  Linotte
//
//  Created by stant on 26/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>

#import "CCAddAddressViewControllerProtocol.h"
#import "CCAddAddressAtLocationViewControllerDelegate.h"

#import "CCAddAddressAtLocationViewDelegate.h"

@interface CCAddAddressAtLocationViewController : UIViewController<CCAddAddressViewControllerProtocol, CCAddAddressAtLocationViewDelegate, CLLocationManagerDelegate>

@property(nonatomic, weak)id<CCAddAddressAtLocationViewControllerDelegate> delegate;

@end
