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

- (void)setupEmptyView;
- (void)removeEmptyView;

- (void)reloadData;
- (void)reloadVisibleCells;
- (void)reloadCellsAtIndexes:(NSIndexSet *)indexSet;
- (void)insertCellsAtIndexes:(NSIndexSet *)indexSet;
- (void)deleteCellsAtIndexes:(NSIndexSet *)indexSet;

- (void)unselect;
- (void)showConfirmationHUD:(NSString *)detailText;

@end
