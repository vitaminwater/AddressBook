//
//  CCListSettingsViewDelegate.h
//  Linotte
//
//  Created by stant on 06/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCAddressListSettingsViewDelegate <NSObject>

// - (void)closeListSettingsView:(id)sender success:(BOOL)success;

- (NSString *)addressName;

- (NSUInteger)numberOfLists;
- (NSString *)listNameAtIndex:(NSUInteger)index;
- (NSString *)listIconAtIndex:(NSUInteger)index;

- (NSUInteger)createListWithName:(NSString *)name;
- (void)removeListAtIndex:(NSUInteger)index;
- (void)listSelectedAtIndex:(NSUInteger)index;
- (void)listUnselectedAtIndex:(NSUInteger)index;
- (BOOL)isListSelectedAtIndex:(NSUInteger)index;

@end
