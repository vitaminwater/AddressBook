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

@interface CCListView : UIView<UITableViewDataSource, UITableViewDelegate, CCListViewTableViewCellDelegate>

@property(nonatomic, weak)id<CCListViewDelegate> delegate;

- (void)reloadAddressList;
- (void)reloadVisibleAddresses;
- (void)insertAddressAtIndex:(NSUInteger)index;
- (void)deleteAddressAtIndex:(NSUInteger)index;

@end
