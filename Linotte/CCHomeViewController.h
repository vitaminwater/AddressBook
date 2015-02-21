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

#import "CCOutputViewControllerDelegate.h"
#import "CCSearchViewControllerDelegate.h"
#import "CCChildRootViewControllerProtocol.h"

@interface CCHomeViewController : UIViewController<CCChildRootViewControllerProtocol, CCHomeViewDelegate, CCListViewControllerDelegate, CCOutputViewControllerDelegate, CCSearchViewControllerDelegate>

@end
