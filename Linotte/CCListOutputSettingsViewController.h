//
//  CCListOutputExpandedSettingsViewController.h
//  Linotte
//
//  Created by stant on 28/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCSettingsViewController.h"

#import "CCListOutputSettingsViewDelegate.h"
#import "CCListOutputSettingsViewControllerDelegate.h"

@interface CCListOutputSettingsViewController : CCSettingsViewController<CCListOutputSettingsViewDelegate>

@property(nonatomic, weak)id<CCListOutputSettingsViewControllerDelegate> delegate;

@end
