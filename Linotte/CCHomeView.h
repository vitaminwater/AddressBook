//
//  CCMainView.h
//  Linotte
//
//  Created by stant on 07/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCHomeViewDelegate.h"

@class CCAnimationDelegator;

@interface CCHomeView : UIView<UITextFieldDelegate>

@property(nonatomic, assign)id<CCHomeViewDelegate> delegate;

- (instancetype)initWithListView:(UIView *)listView animationDelegator:(CCAnimationDelegator *)animatorDelegator;

- (void)presentSearchViewControllerView:(UIView *)searchViewControllerView;
- (void)dismissSearchViewControllerView;

- (void)searchFieldResignFirstResponder;
- (void)setSelectedButtonAtIndex:(NSUInteger)index;

@end
