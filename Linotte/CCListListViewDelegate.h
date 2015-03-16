//
//  CCListListViewDelegate.h
//  Linotte
//
//  Created by stant on 14/03/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCListListViewDelegate <NSObject>

- (NSUInteger)numberOfSections;
- (NSUInteger)numberOfListsInSection:(NSUInteger)section;
- (NSString *)titleForSection:(NSUInteger)section;
- (NSString *)listNameAtIndex:(NSUInteger)index inSection:(NSUInteger)section;
- (UIImage *)listIconAtIndex:(NSUInteger)index inSection:(NSUInteger)section;
- (NSUInteger)numberOfAddressAtIndex:(NSUInteger)index inSection:(NSUInteger)section;
- (NSString *)authorNameAtIndex:(NSUInteger)index inSection:(NSUInteger)section;

@end
