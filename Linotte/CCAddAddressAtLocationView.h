//
//  CCAddAddressAtLocationView.h
//  Linotte
//
//  Created by stant on 26/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCAddAddressAtLocationViewDelegate.h"

@interface CCAddAddressAtLocationView : UIView

@property(nonatomic, weak)id<CCAddAddressAtLocationViewDelegate> delegate;

- (void)setFirstInputAsFirstResponder;

@end
