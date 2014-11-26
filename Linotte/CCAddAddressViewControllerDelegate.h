//
//  CCAddViewControllerDelegate.h
//  Linotte
//
//  Created by stant on 07/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCAddress;

@protocol CCAddAddressViewControllerDelegate <NSObject>

- (void)addAddressViewController:(id)sender preSaveAddress:(CCAddress *)address;
- (void)addAddressViewController:(id)sender postSaveAddress:(CCAddress *)address;

- (void)addAddressViewControllerExpandAddView:(id)sender;
- (void)addAddressViewControllerReduceAddView:(id)sender;

@end
