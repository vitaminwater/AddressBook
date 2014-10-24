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

@property(nonatomic, weak)id<CCListViewTableViewCellDelegate> delegate;
@property(nonatomic, readonly)UIImageView *markerImageView;
@property(nonatomic, assign)BOOL directionHidden;
@property(nonatomic, assign)BOOL deletable;

- (void)setNotificationEnabled:(BOOL)notificationEnabled;
- (void)setAngle:(double)angle;

@end
