//
//  CCSettingsViewController.h
//  Linotte
//
//  Created by stant on 19/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCSettingsViewDelegate.h"

#import "CCSettingsViewControllerDelegate.h"

@interface CCSettingsViewController : UIViewController<CCSettingsViewDelegate>

@property(nonatomic, assign)id<CCSettingsViewControllerDelegate> delegate;
@property(nonatomic, strong)UIView *contentView;

- (void)loadContentView;

@end
