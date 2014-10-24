//
//  CCListViewControllerDelegate.h
//  Linotte
//
//  Created by stant on 07/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCAddress;
@class CCList;

@protocol CCListViewControllerDelegate <NSObject>

- (UIView *)getEmptyView;

- (void)addressSelected:(CCAddress *)address;
- (void)listSelected:(CCList *)list;

- (void)deleteAddress:(CCAddress *)address;
- (void)deleteList:(CCList *)list;

@end
