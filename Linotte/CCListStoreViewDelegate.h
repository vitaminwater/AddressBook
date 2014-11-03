//
//  CCListStoreViewDelegate.h
//  Linotte
//
//  Created by stant on 09/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCListStoreViewDelegate <NSObject>

- (void)listSelectedAtIndex:(NSUInteger)index;

- (NSUInteger)numberOfLists;
- (NSString *)nameForListAtIndex:(NSUInteger)index;
- (NSString *)iconForListAtIndex:(NSUInteger)index;

@end
