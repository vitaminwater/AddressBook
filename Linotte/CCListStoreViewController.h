//
//  CCListStoreViewController.h
//  Linotte
//
//  Created by stant on 09/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>

#import "CCListStoreViewDelegate.h"

#import "CCListStoreViewControllerDelegate.h"

#import "CCListInstallerViewController.h"

@interface CCListStoreViewController : UIViewController<CCListStoreViewDelegate, CCListInstallerViewControllerDelegate, CLLocationManagerDelegate>

@property(nonatomic, assign)id<CCListStoreViewControllerDelegate> delegate;

@end
