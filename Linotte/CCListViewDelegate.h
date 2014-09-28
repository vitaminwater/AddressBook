//
//  CCListViewDelegate.h
//  Linotte
//
//  Created by stant on 06/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCListViewDelegate <NSObject>

- (void)showOptionViewProgress:(CGFloat)pixels;
- (void)showOptionView;
- (void)hideOptionViewProgress:(CGFloat)pixels;
- (void)hideOptionView;

- (UIView *)getEmptyView;

- (void)didSelectListItemAtIndex:(NSUInteger)index;
- (void)deleteListItemAtIndex:(NSUInteger)index;

- (void)setNotificationEnabled:(BOOL)enabled atIndex:(NSUInteger)index;

- (double)distanceForListItemAtIndex:(NSUInteger)index;
- (double)angleForListItemAtIndex:(NSUInteger)index;
- (UIImage *)iconForListItemAtIndex:(NSUInteger)index;
- (NSString *)nameForListItemAtIndex:(NSUInteger)index;
- (NSString *)infoForListItemAtIndex:(NSUInteger)index;
- (BOOL)notificationEnabledForListItemAtIndex:(NSUInteger)index;
- (BOOL)orientationAvailableAtIndex:(NSUInteger)index;
- (NSUInteger)numberOfListItems;

@end
