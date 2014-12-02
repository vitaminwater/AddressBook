//
//  CCSwapperViewController.h
//  Linotte
//
//  Created by stant on 30/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCSwapperViewControllerDelegate.h"

#import "CCSwapperViewDelegate.h"

@interface CCSwapperViewController : UIViewController<CCSwapperViewDelegate>

@property(nonatomic, weak)id<CCSwapperViewControllerDelegate> delegate;

@property(nonatomic, readonly)UIViewController *currentViewController;

- (instancetype)initWithFirstViewController:(UIViewController *)firstViewController;

- (void)swapToViewController:(UIViewController *)viewController;

@end
