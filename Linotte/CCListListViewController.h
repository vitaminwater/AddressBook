//
//  CCListListViewController.h
//  Linotte
//
//  Created by stant on 14/03/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCListListViewDelegate.h"
#import "CCListListViewControllerDelegate.h"

@interface CCListListViewController : UIViewController<CCListListViewDelegate>

@property(nonatomic, weak)id<CCListListViewControllerDelegate> delegate;

@end
