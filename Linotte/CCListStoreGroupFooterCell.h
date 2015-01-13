//
//  CCListStoreGroupFooterCell.h
//  Linotte
//
//  Created by stant on 05/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCListStoreGroupFooterCellDelegate.h"

@interface CCListStoreGroupFooterCell : UICollectionViewCell

@property(nonatomic, weak)id<CCListStoreGroupFooterCellDelegate> delegate;
@property(nonatomic, strong)NSIndexPath *indexPath;

@end
