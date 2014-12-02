//
//  CCAddAddressView.h
//  Linotte
//
//  Created by stant on 01/12/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCAddAddressViewDelegate.h"

@interface CCAddAddressView : UIView

@property(nonatomic, weak)id<CCAddAddressViewDelegate> delegate;

- (instancetype)initWithSwapperView:(UIView *)swapperView;

@end
