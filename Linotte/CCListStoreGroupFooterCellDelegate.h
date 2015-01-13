
//
//  CCListStoreGroupHeaderCellDelegate.h
//  Linotte
//
//  Created by stant on 05/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCListStoreGroupFooterCell;

@protocol CCListStoreGroupFooterCellDelegate <NSObject>

- (void)groupCellPressed:(CCListStoreGroupFooterCell *)sender;

@end
