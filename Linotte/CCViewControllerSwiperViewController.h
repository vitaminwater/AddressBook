//
//  CCViewControllerSwiperViewController.h
//  Linotte
//
//  Created by stant on 23/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCViewControllerSwiperViewControllerDelegate.h"
#import "CCViewControllerSwiperViewDelegate.h"


@interface CCViewControllerSwiperViewController : UIViewController<CCViewControllerSwiperViewDelegate>

@property(nonatomic, weak)id<CCViewControllerSwiperViewControllerDelegate> delegate;

@property(nonatomic, strong)NSArray *viewControllers;
@property(nonatomic, readonly)UIViewController *currentViewController;

- (instancetype)initWithViewControllers:(NSArray *)viewControllers edgeOnly:(BOOL)edgeOnly startViewControllerIndex:(NSUInteger)startViewControllerIndex;
- (void)setCurrentViewControllerIndex:(NSUInteger)currentViewController;

@end
