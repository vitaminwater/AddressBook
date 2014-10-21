//
//  CCListOutputExpandedSettingsViewDelegate.h
//  Linotte
//
//  Created by stant on 28/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCListListExpandedSettingsViewDelegate <NSObject>

- (NSUInteger)numberOfLists;
- (NSString *)listNameAtIndex:(NSUInteger)index;
- (NSString *)listIconAtIndex:(NSUInteger)index;

- (void)listSelectedAtIndex:(NSUInteger)index;
- (void)listUnselectedAtIndex:(NSUInteger)index;
- (BOOL)isListSelectedAtIndex:(NSUInteger)index;

@end
