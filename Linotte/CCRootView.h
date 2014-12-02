//
//  CCRootView.h
//  Linotte
//
//  Created by stant on 01/12/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCRootViewDelegate.h"

@interface CCRootView : UIView<UITabBarDelegate>

@property(nonatomic, weak)id<CCRootViewDelegate> delegate;

- (instancetype)initWithSwiperView:(UIView *)swiperView;

- (void)setSelectedTabItem:(NSUInteger)index;

@end
