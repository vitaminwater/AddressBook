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

#import "CCViewControllerSwiperViewControllerDelegate.h"

#import "CCLinotteBrowserViewControllerDelegate.h"

@interface CCRootViewController : UIViewController<UINavigationControllerDelegate, CCRootViewDelegate, CCSplashViewControllerDelegate, CCViewControllerSwiperViewControllerDelegate, CCLinotteBrowserViewControllerDelegate>

@end
