//
//  CCListView.h
//  Linotte
//
//  Created by stant on 06/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCListViewDelegate.h"

#import "CCListViewTableViewCellDelegate.h"

@class CCListViewContentProvider;

@interface CCListView : UIView<UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, CCListViewTableViewCellDelegate>

@property(nonatomic, weak)id<CCListViewDelegate> delegate;

- (void)reloadListItemList;
- (void)reloadVisibleListItems;
- (void)insertListItemAtIndex:(NSUInteger)index;
- (void)deleteListItemAtIndex:(NSUInteger)index;

- (void)unselect;

@end
