//
//  CCViewControllerSwiperViewDelegate.h
//  Linotte
//
//  Created by stant on 23/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCViewControllerSwiperViewDelegate <NSObject>

- (void)currentViewControllerChangedToIndex:(NSUInteger)index;
- (NSString *)nameForViewControllerAtIndex:(NSUInteger)index;

@end
