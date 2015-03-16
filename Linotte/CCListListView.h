//
//  CCListListView.h
//  Linotte
//
//  Created by stant on 14/03/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCListListViewDelegate.h"

@interface CCListListView : UIView<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, weak)id<CCListListViewDelegate> delegate;

- (void)reloadListView;

@end
