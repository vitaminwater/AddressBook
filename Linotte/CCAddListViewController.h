//
//  CCAddListViewController.h
//  Linotte
//
//  Created by stant on 17/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCAddListViewDelegate.h"
#import "CCAddListViewControllerDelegate.h"

@interface CCAddListViewController : UIViewController<CCAddListViewDelegate>

@property(nonatomic, assign)id<CCAddListViewControllerDelegate> delegate;

@end
