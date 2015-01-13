//
//  CCHomeListStoreViewDelegate.h
//  Linotte
//
//  Created by stant on 04/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCListStoreHomeViewDelegate <NSObject>

- (void)groupSelectedAtIndex:(NSUInteger)groupIndex;
- (void)listSelectedAtIndex:(NSUInteger)index forGroupAtIndex:(NSUInteger)index;

- (NSUInteger)numberOfGroups;
- (NSString *)nameForGroupAtIndex:(NSUInteger)index;

- (NSUInteger)numberOfListsForGroupAtIndex:(NSUInteger)index;
- (NSString *)nameForListAtIndex:(NSUInteger)index forGroupAtIndex:(NSUInteger)index;
- (NSString *)iconUrlForListAtIndex:(NSUInteger)index forGroupAtIndex:(NSUInteger)index;

@end
