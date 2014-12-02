//
//  CCViewControllerSwiperViewDelegate.h
//  Linotte
//
//  Created by stant on 23/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCViewControllerSwiperViewDelegate <NSObject>

- (void)currentViewControllerWillChangeToIndex:(NSUInteger)index fromIndex:(NSUInteger)fromIndex;
- (void)currentViewControllerDidChangeToIndex:(NSUInteger)index fromIndex:(NSUInteger)fromIndex;
- (NSString *)nameForViewControllerAtIndex:(NSUInteger)index;

@end
