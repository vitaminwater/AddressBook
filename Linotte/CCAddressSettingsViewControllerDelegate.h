//
//  CCAddressSettingsViewControllerDelegate.h
//  Linotte
//
//  Created by stant on 19/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CCSettingsViewControllerDelegate.h"

@class CCAddress;

@protocol CCAddressSettingsViewControllerDelegate <CCSettingsViewControllerDelegate>

- (void)showListSettings;

@end
