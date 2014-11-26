//
//  CCMainViewController.h
//  Linotte
//
//  Created by stant on 07/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCHomeViewDelegate.h"

#import "CCListViewControllerDelegate.h"
#import "CCAddAddressByNameViewControllerDelegate.h"
#import "CCAddAddressByAddressViewControllerDelegate.h"
#import "CCAddAddressAtLocationViewControllerDelegate.h"

#import "CCViewControllerSwiperViewControllerDelegate.h"

#import "CCSplashViewControllerDelegate.h"

#import "CCListListViewControllerDelegate.h"
#import "CCListStoreViewControllerDelegate.h"

#import "CCListOutputViewControllerDelegate.h"
#import "CCOutputViewControllerDelegate.h"

@interface CCHomeViewController : UIViewController<CCHomeViewDelegate, CCListViewControllerDelegate, CCAddAddressByNameViewControllerDelegate, CCAddAddressByAddressViewControllerDelegate, CCAddAddressAtLocationViewControllerDelegate, CCSplashViewControllerDelegate, CCListListViewControllerDelegate, CCListStoreViewControllerDelegate, CCListOutputViewControllerDelegate, CCOutputViewControllerDelegate, CCViewControllerSwiperViewControllerDelegate>

@end
