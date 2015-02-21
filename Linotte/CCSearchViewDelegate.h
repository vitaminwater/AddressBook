//
//  CCSearchViewDelegate.h
//  Linotte
//
//  Created by stant on 11/02/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCSearchViewDelegate <NSObject>

- (UIImage *)listIconAtIndex:(NSUInteger)index;
- (NSString *)listNameAtIndex:(NSUInteger)index;
- (NSString *)listDetailAtIndex:(NSUInteger)index;

- (UIImage *)addressIconAtIndex:(NSUInteger)index;
- (NSString *)addressNameAtIndex:(NSUInteger)index;
- (NSString *)addressDetailAtIndex:(NSUInteger)index;

- (NSUInteger)numberOfLists;
- (NSUInteger)numberOfAddresses;

- (void)listSelectedAtIndex:(NSUInteger)index;
- (void)addressSelectedAtIndex:(NSUInteger)index;

- (void)closeButtonPressed;

@end
