//
//  CCFirstAddressDisplaySettingsViewController.h
//  Linotte
//
//  Created by stant on 19/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCSettingsViewController.h"

#import "CCFirstAddressDisplaySettingsViewControllerDelegate.h"
#import "CCFirstDisplaySettingsViewDelegate.h"

@class CCAddress;

@interface CCFirstAddressDisplaySettingsViewController : CCSettingsViewController<CCFirstDisplaySettingsViewDelegate>

@property(nonatomic, assign)id<CCFirstAddressDisplaySettingsViewControllerDelegate> delegate;

- (instancetype)initWithAddress:(CCAddress *)address;

@end
