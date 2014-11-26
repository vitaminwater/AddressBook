//
//  CCAddViewController.h
//  Linotte
//
//  Created by stant on 06/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCAutocompleteAddAddressViewController.h"

#import "CCAddAddressByNameViewControllerDelegate.h"

#import "CCAddAddressByNameViewDelegate.h"

@interface CCAddAddressByNameViewController : CCAutocompleteAddAddressViewController<CCAddAddressByNameViewDelegate>

@property(nonatomic, weak)id<CCAddAddressByNameViewControllerDelegate> delegate;

@end
