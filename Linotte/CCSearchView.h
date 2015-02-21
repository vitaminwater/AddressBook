//
//  CCSearchView.h
//  Linotte
//
//  Created by stant on 11/02/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCSearchViewDelegate.h"

@interface CCSearchView : UIView<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, weak)id<CCSearchViewDelegate> delegate;

- (void)updateVisibleCells;
- (void)reloadTableView;

@end
