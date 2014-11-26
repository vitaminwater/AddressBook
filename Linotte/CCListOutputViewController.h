//
//  CCListOutputViewController.h
//  Linotte
//
//  Created by stant on 10/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCListOutputViewDelegate.h"

#import "CCListOutputSettingsViewControllerDelegate.h"

#import "CCListOutputListEmptyViewDelegate.h"
#import "CCListOutputViewControllerDelegate.h"
#import "CCAddAddressByNameViewController.h"
#import "CCFirstListDisplaySettingsViewControllerDelegate.h"

#import "CCOutputViewControllerDelegate.h"

#import "CCListViewController.h"

@class CCList;

@interface CCListOutputViewController : UIViewController<CCListOutputViewDelegate, CCListOutputSettingsViewControllerDelegate, CCListOutputListEmptyViewDelegate, CCListViewControllerDelegate, CCAddAddressByNameViewControllerDelegate, CCOutputViewControllerDelegate, CCFirstListDisplaySettingsViewControllerDelegate>

@property(nonatomic, assign)id<CCListOutputViewControllerDelegate> delegate;

- (instancetype)initWithList:(CCList *)list listIsNew:(BOOL)listIsNew;
- (instancetype)initWithList:(CCList *)list;

@end
