//
//  CCListOutputAddressListTableViewCell.h
//  Linotte
//
//  Created by stant on 26/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCListOutputAddressListTableViewCellDelegate.h"

@interface CCListOutputAddressListTableViewCell : UITableViewCell

@property(nonatomic, assign)id<CCListOutputAddressListTableViewCellDelegate> delegate;

@property(nonatomic, assign)BOOL isAdded;

- (void)setName:(NSString *)name;
- (void)setAddress:(NSString *)address;

@end
