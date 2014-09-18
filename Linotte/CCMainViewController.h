//
//  CCMainViewController.h
//  Linotte
//
//  Created by stant on 07/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCMainViewDelegate.h"

#import "CCListViewControllerDelegate.h"
#import "CCAddAddressViewControllerDelegate.h"

#import "CCSplashViewControllerDelegate.h"

#import "CCListListViewControllerDelegate.h"
#import "CCListStoreViewControllerDelegate.h"

@interface CCMainViewController : UIViewController<CCMainViewDelegate, CCListViewControllerDelegate, CCAddAddressViewControllerDelegate, CCSplashViewControllerDelegate, CCListListViewControllerDelegate, CCListStoreViewControllerDelegate>

@end
