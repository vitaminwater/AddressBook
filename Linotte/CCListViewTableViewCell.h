//
//  CCListViewCellTableViewCell.h
//  Linotte
//
//  Created by stant on 07/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCListViewTableViewCellDelegate.h"

@interface CCListViewTableViewCell : UITableViewCell

@property(nonatomic, strong)NSString *colorCode;
@property(nonatomic, assign)double angle;
@property(nonatomic, weak)id<CCListViewTableViewCellDelegate> delegate;
@property(nonatomic, readonly)UIImageView *markerImageView;

@end
