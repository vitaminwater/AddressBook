//
//  CCFirstListDisplaySettingsViewController.h
//  Linotte
//
//  Created by stant on 19/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCSettingsViewController.h"

#import "CCFirstListDisplaySettingsViewControllerDelegate.h"

#import "CCFirstListDisplaySettingsViewDelegate.h"

@class CCList;

@interface CCFirstListDisplaySettingsViewController : CCSettingsViewController<CCFirstListDisplaySettingsViewDelegate>

@property(nonatomic, assign)id<CCFirstListDisplaySettingsViewControllerDelegate> delegate;

- (instancetype)initWithList:(CCList *)list;

@end
