//
//  CCMainView.h
//  Linotte
//
//  Created by stant on 07/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCMainViewDelegate.h"

@class CCListView;

@interface CCMainView : UIView

@property(nonatomic, assign)BOOL addViewExpanded;
@property(nonatomic, assign)id<CCMainViewDelegate> delegate;

- (void)setupAddView:(UIView *)addView;
- (void)setupListView:(CCListView *)listView;

- (void)setupLayout;

@end
