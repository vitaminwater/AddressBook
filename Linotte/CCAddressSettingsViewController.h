//
//  CCAddressSettingsViewController.h
//  Linotte
//
//  Created by stant on 19/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCSettingsViewController.h"

#import "CCAddressSettingsViewControllerDelegate.h"

#import "CCAddressSettingsViewDelegate.h"

@class CCAddress;

@interface CCAddressSettingsViewController : CCSettingsViewController<CCAddressSettingsViewDelegate>

@property(nonatomic, assign)id<CCAddressSettingsViewControllerDelegate> delegate;

- (instancetype)initWithAddress:(CCAddress *)address;

@end
