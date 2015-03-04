//
//  CCFlatListStoreViewDelegate.h
//  Linotte
//
//  Created by stant on 05/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCFlatListStoreViewDelegate <NSObject>

- (void)listSelectedAtIndex:(NSUInteger)index;

- (NSUInteger)numberOfLists;
- (NSString *)nameForListAtIndex:(NSUInteger)index;
- (NSString *)authorForListAtIndex:(NSUInteger)index;
- (NSString *)iconUrlForListAtIndex:(NSUInteger)index;

@end
