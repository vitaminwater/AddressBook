//
//  CCListStoreView.h
//  Linotte
//
//  Created by stant on 04/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCCListStoreCell @"kCCListStoreCell"
#define kCCListStoreGroupHeaderCell @"kCCListStoreGroupHeaderCell"
#define kCCListStoreGroupFooterCell @"kCCListStoreGroupFooterCell"

@class CCListStoreTableViewCell;

@interface CCBaseListStoreView : UIView

@property(nonatomic, strong)UITableView *listView;

- (void)reloadData;

- (void)unreachable;
- (void)reachable;

@end
