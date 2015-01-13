//
//  CCAddAddressTabButtons.h
//  Linotte
//
//  Created by stant on 06/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCAddAddressTabButtonsDelegate.h"

#define kCCButtonViewHeight @40

@interface CCAddAddressTabButtons : UIView

@property(nonatomic, weak)id<CCAddAddressTabButtonsDelegate> delegate;

- (void)setSelectedTabButton:(CCAddAddressType)type;

@end
