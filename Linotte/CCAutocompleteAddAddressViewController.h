//
//  CCAddAddressViewController.h
//  Linotte
//
//  Created by stant on 24/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCAddAddressViewControllerProtocol.h"
#import "CCAutocompleterDelegate.h"
#import "CCAutocompleteAddAddressViewDelegate.h"
#import "CCAutocompleteAddAddressViewControllerDelegate.h"

@class CCBaseAutoComplete;

@interface CCAutocompleteAddAddressViewController : UIViewController<CCAddAddressViewControllerProtocol, CCAutocompleteAddAddressViewDelegate, CCAutocompleterDelegate>

@property(nonatomic, weak)id<CCAutocompleteAddAddressViewControllerDelegate> delegate;

@property(nonatomic, strong)CCBaseAutoComplete *autoComplete;

- (instancetype)initWithAutocompleter:(CCBaseAutoComplete *)autocomplete;

@end
