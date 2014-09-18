//
//  CCListListView.h
//  Linotte
//
//  Created by stant on 13/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCListListViewDelegate.h"

@interface CCListListView : UIView

@property(nonatomic, assign)id<CCListListViewDelegate> delegate;

- (void)setupAddListView:(UIView *)addListView;
- (void)setupListView:(UIView *)listListView;
- (void)setupLayout;

@end
