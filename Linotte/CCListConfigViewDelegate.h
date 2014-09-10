//
//  CCListConfigViewDelegate.h
//  Linotte
//
//  Created by stant on 09/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCListConfigViewDelegate <NSObject>

- (NSUInteger)numberOfLists;
- (NSString *)listNameAtIndex:(NSUInteger)index;
- (NSString *)listIconAtIndex:(NSUInteger)index;

- (NSUInteger)createListWithName:(NSString *)name;
- (void)removeListAtIndex:(NSUInteger)index;
- (void)listExpandedAtIndex:(NSUInteger)index;
- (void)listUnexpandedAtIndex:(NSUInteger)index;
- (BOOL)isListExpandedAtIndex:(NSUInteger)index;

@end
