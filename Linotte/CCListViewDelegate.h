//
//  CCListViewDelegate.h
//  Linotte
//
//  Created by stant on 06/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCListViewDelegate <NSObject>

- (void)didSelectListItemAtIndex:(NSUInteger)index color:(NSString *)color;
- (void)deleteListItemAtIndex:(NSUInteger)index;

- (double)distanceForListItemAtIndex:(NSUInteger)index;
- (double)angleForListItemAtIndex:(NSUInteger)index;
- (NSString *)nameForListItemAtIndex:(NSUInteger)index;
- (NSUInteger)numberOfListItems;

- (void)showListManagement;
- (void)showListStore;

@end
