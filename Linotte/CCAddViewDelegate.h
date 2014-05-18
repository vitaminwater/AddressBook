//
//  CCAddViewDelegate.h
//  Linotte
//
//  Created by stant on 06/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCAddView;

@protocol CCAddViewDelegate <NSObject>

- (void)reduceAddView;

#pragma mark - auto completion methods

- (void)autocompleteName:(NSString *)name;

- (NSString *)nameForAutocompletionResultAtIndex:(NSUInteger)index;
- (NSString *)addressForAutocompletionResultAtIndex:(NSUInteger)index;
- (NSUInteger)numberOfAutocompletionResults;

- (void)autocompletionResultSelectedAtIndex:(NSUInteger)index;

@end
