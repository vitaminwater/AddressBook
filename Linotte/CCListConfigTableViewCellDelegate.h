//
//  CCListConfigTableViewCellDelegate.h
//  Linotte
//
//  Created by stant on 09/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCListConfigTableViewCellDelegate <NSObject>

- (void)checkedCell:(id)sender;
- (void)uncheckedCell:(id)sender;

@end
