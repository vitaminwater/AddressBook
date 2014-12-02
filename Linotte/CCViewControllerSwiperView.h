//
//  CCViewControllerSwiperView.h
//  Linotte
//
//  Created by stant on 23/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCViewControllerSwiperViewDelegate.h"

@interface CCViewControllerSwiperView : UIView<UIGestureRecognizerDelegate>

@property(nonatomic, weak)id<CCViewControllerSwiperViewDelegate> delegate;
@property(nonatomic, assign)NSUInteger currentViewIndex;

- (instancetype)initWithViewControllerViews:(NSArray *)viewControllerViews edgeOnly:(BOOL)edgeOnly startViewControllerViewIndex:(NSUInteger)startViewControllerViewIndex;

@end
