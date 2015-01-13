//
//  CCAllAddAddressViewController.h
//  Linotte
//
//  Created by stant on 26/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCSwapperViewController.h"

#import "CCAddAddressViewDelegate.h"

#import "CCSwapperViewControllerDelegate.h"

#import "CCAddAddressByNameViewControllerDelegate.h"
#import "CCAddAddressByAddressViewControllerDelegate.h"
#import "CCAddAddressAtLocationViewControllerDelegate.h"

#import "CCChildRootViewControllerProtocol.h"

@interface CCAddAddressViewController : UIViewController<CCChildRootViewControllerProtocol, CCSwapperViewControllerDelegate, CCAddAddressViewDelegate, CCAddAddressByNameViewControllerDelegate, CCAddAddressByAddressViewControllerDelegate, CCAddAddressAtLocationViewControllerDelegate>

@end
