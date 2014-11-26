//
//  CCAddView.h
//  Linotte
//
//  Created by stant on 06/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCAutocompleteAddAddressView.h"

#import "CCAddAddressByNameViewDelegate.h"

@interface CCAddAddressByNameView : CCAutocompleteAddAddressView

@property(nonatomic, weak)id<CCAddAddressByNameViewDelegate> delegate;

@end
