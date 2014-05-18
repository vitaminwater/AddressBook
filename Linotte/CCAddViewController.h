//
//  CCAddViewController.h
//  Linotte
//
//  Created by stant on 06/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>

#import "CCAddViewControllerDelegate.h"

#import "CCAddViewDelegate.h"

@interface CCAddViewController : UIViewController<CCAddViewDelegate, CLLocationManagerDelegate>

@property(nonatomic, weak)id<CCAddViewControllerDelegate> delegate;

@end
