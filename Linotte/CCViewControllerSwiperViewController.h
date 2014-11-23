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

- (instancetype)initWithViewControllers:(NSArray *)viewControllers;

@end
