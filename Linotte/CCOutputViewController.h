//
//  CCOutputViewController.h
//  Linotte
//
//  Created by stant on 12/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>

#import "CCOutputViewDelegate.h"

@class CCAddress;

@interface CCOutputViewController : UIViewController<CCOutputViewDelegate, CLLocationManagerDelegate>

- (id)initWithAddress:(CCAddress *)address;

@end
