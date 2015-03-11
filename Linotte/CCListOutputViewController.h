//
//  CCListOutputViewController.h
//  Linotte
//
//  Created by stant on 10/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCListOutputViewDelegate.h"
#import "CCModelChangeMonitor.h"

#import "CCListOutputSettingsViewControllerDelegate.h"

#import "CCListOutputListEmptyViewDelegate.h"
#import "CCFirstListDisplaySettingsViewControllerDelegate.h"

#import "CCOutputViewControllerDelegate.h"
#import "CCSearchViewControllerDelegate.h"

#import "CCListViewController.h"

@class CCList;

@interface CCListOutputViewController : UIViewController<CCListOutputViewDelegate, CCListOutputSettingsViewControllerDelegate, CCListOutputListEmptyViewDelegate, CCListViewControllerDelegate, CCOutputViewControllerDelegate, CCFirstListDisplaySettingsViewControllerDelegate, CCModelChangeMonitorDelegate, CCSearchViewControllerDelegate>

- (instancetype)initWithList:(CCList *)list listIsNew:(BOOL)listIsNew;
- (instancetype)initWithList:(CCList *)list;

@end
