//
//  CCListViewDelegate.h
//  Linotte
//
//  Created by stant on 06/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCListViewDelegate <NSObject>

- (void)showOptionView;
- (void)hideOptionView;

- (void)didSelectListItemAtIndex:(NSUInteger)index;
- (void)deleteListItemAtIndex:(NSUInteger)index;

- (void)setNotificationEnabled:(BOOL)enabled atIndex:(NSUInteger)index;

- (double)distanceForListItemAtIndex:(NSUInteger)index;
- (double)angleForListItemAtIndex:(NSUInteger)index;
- (UIImage *)iconForListItemAtIndex:(NSUInteger)index;
- (NSString *)nameForListItemAtIndex:(NSUInteger)index;
- (BOOL)notificationEnabledForListItemAtIndex:(NSUInteger)index;
- (NSUInteger)numberOfListItems;

@end
