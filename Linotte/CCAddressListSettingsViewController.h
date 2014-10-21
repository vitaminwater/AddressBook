//
//  CCListSettingsViewController.h
//  Linotte
//
//  Created by stant on 19/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCSettingsViewController.h"

#import "CCAddressListSettingsViewDelegate.h"
#import "CCAddressListSettingsViewControllerDelegate.h"

@class CCAddress;

@interface CCAddressListSettingsViewController : CCSettingsViewController<CCAddressListSettingsViewDelegate>

@property(nonatomic, weak)id<CCAddressListSettingsViewControllerDelegate> delegate;

- (instancetype)initWithAddress:(CCAddress *)address;

@end
