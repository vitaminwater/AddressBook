//
//  CCListStoreGroupFooterCell.h
//  Linotte
//
//  Created by stant on 05/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCListStoreGroupFooterCellDelegate.h"

@interface CCListStoreGroupFooterCell : UITableViewHeaderFooterView

@property(nonatomic, weak)id<CCListStoreGroupFooterCellDelegate> delegate;
@property(nonatomic, assign)NSUInteger section;

@end
