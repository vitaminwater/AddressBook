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

- (void)preSaveAddress:(CCAddress *)address;
- (void)postSaveAddress:(CCAddress *)address;

- (void)expandAddView;
- (void)reduceAddView;

@end
