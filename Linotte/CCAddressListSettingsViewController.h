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

@property(nonatomic, assign)id<CCAddressListSettingsViewControllerDelegate> delegate;

- (id)initWithAddress:(CCAddress *)address;

@end
