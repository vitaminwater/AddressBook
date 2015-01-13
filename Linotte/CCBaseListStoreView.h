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

@class CCListStoreCollectionViewCell;

@interface CCBaseListStoreView : UIView

@property(nonatomic, strong)UICollectionView *listView;

- (void)reloadData;

- (void)unreachable;
- (void)reachable;

- (void)addListInstallerView:(UIView *)view;
- (void)removeListInstallerView:(UIView *)view completionBlock:(void(^)())completionBlock;

@end
