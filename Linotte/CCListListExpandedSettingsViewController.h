//
//  CCListOutputExpandedSettingsViewController.h
//  Linotte
//
//  Created by stant on 28/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCSettingsViewController.h"

#import "CCListListExpandedSettingsViewDelegate.h"
#import "CCListListExpandedSettingsViewControllerDelegate.h"

@interface CCListListExpandedSettingsViewController : CCSettingsViewController<CCListListExpandedSettingsViewDelegate>

@property(nonatomic, weak)id<CCListListExpandedSettingsViewControllerDelegate> delegate;

@end
