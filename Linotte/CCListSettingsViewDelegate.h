//
//  CCListSettingsViewDelegate.h
//  Linotte
//
//  Created by stant on 06/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCListSettingsViewDelegate <NSObject>

- (void)closeListSettingsView:(id)sender success:(BOOL)success;

- (NSString *)addressName;

- (NSUInteger)numberOfLists;
- (NSString *)listNameAtIndex:(NSUInteger)index;
- (NSString *)listIconAtIndex:(NSUInteger)index;

- (void)listSelectedAtIndex:(NSUInteger)index;
- (void)createListWithName:(NSString *)name;
- (NSInteger)selectedListIndex;;

@end
