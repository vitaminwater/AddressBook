//
//  CCSwapperView.h
//  Linotte
//
//  Created by stant on 30/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCSwapperViewDelegate.h"

@interface CCSwapperView : UIView

@property(nonatomic, weak)id<CCSwapperViewDelegate> delegate;

- (instancetype)initWithFirstView:(UIView *)view;

- (void)swapCurrentViewWithView:(UIView *)view completionBlock:(void(^)())completionBlock;

@end
