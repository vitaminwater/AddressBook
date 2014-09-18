//
//  CCListListViewController.h
//  Linotte
//
//  Created by stant on 13/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCAddListViewControllerDelegate.h"
#import "CCListViewControllerDelegate.h"

#import "CCListListViewDelegate.h"
#import "CCListListViewControllerDelegate.h"

@interface CCListListViewController : UIViewController<CCAddListViewControllerDelegate, CCListViewControllerDelegate, CCListListViewDelegate>

@property(nonatomic, assign)id<CCListListViewControllerDelegate> delegate;

@end
