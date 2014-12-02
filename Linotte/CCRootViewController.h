//
//  CCRootViewController.h
//  Linotte
//
//  Created by stant on 28/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCRootViewDelegate.h"

#import "CCSplashViewControllerDelegate.h"

#import "CCAddAddressViewControllerDelegate.h"
#import "CCListStoreViewControllerDelegate.h"

#import "CCViewControllerSwiperViewControllerDelegate.h"

@interface CCRootViewController : UIViewController<UINavigationControllerDelegate, CCRootViewDelegate, CCSplashViewControllerDelegate, CCListStoreViewControllerDelegate, CCAddAddressViewControllerDelegate, CCViewControllerSwiperViewControllerDelegate>

@end
