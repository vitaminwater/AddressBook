//
//  CCListViewController.h
//  Linotte
//
//  Created by stant on 06/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>

#import "CCListViewControllerDelegate.h"

#import "CCListViewDelegate.h"

@class CCAddress;

@interface CCListViewController : UIViewController<CCListViewDelegate, CLLocationManagerDelegate>

@property(nonatomic, weak)id<CCListViewControllerDelegate> delegate;

- (void)addressAdded:(CCAddress *)address;

@end
