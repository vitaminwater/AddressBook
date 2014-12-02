//
//  CCAddAddressViewControllerProtocol.h
//  Linotte
//
//  Created by stant on 26/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CCBaseAddAddressViewControllerDelegate.h"

@protocol CCAddAddressViewControllerProtocol <NSObject>

@property(nonatomic, weak)id<CCBaseAddAddressViewControllerDelegate> delegate;
@property(nonatomic, strong)NSString *nameFieldValue;

- (void)setFirstInputAsFirstResponder;
- (void)firstInputResignFirstResponder;

@end
