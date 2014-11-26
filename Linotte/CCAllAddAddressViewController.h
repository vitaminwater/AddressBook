//
//  CCAllAddAddressViewController.h
//  Linotte
//
//  Created by stant on 26/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCViewControllerSwiperViewController.h"

#import "CCAddAddressViewControllerProtocol.h"
#import "CCAddAddressByNameViewControllerDelegate.h"
#import "CCAddAddressByAddressViewControllerDelegate.h"
#import "CCAddAddressAtLocationViewControllerDelegate.h"

#import "CCAllAddressViewControllerDelegate.h"

@interface CCAllAddAddressViewController : CCViewControllerSwiperViewController<CCAddAddressViewControllerProtocol, CCAddAddressByNameViewControllerDelegate, CCAddAddressByAddressViewControllerDelegate, CCAddAddressAtLocationViewControllerDelegate>

@property(nonatomic, weak)id<CCAllAddressViewControllerDelegate> delegate;

@end
