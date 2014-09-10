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

- (void)addressSelected:(CCAddress *)address;
- (void)listSelected:(CCList *)list;

@end
