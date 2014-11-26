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

@interface CCHomeView : UIView

@property(nonatomic, assign)BOOL addViewExpanded;
@property(nonatomic, assign)id<CCHomeViewDelegate> delegate;

- (void)setupAddView:(UIView *)addView;
- (void)setupListView:(UIView *)listView animationDelegator:(CCAnimationDelegator *)animationDelegator;

- (void)setupLayout;

@end
