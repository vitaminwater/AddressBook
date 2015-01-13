//
//  CCAddAddressViewDelegate.h
//  Linotte
//
//  Created by stant on 24/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CCAddAddressTabButtonsDelegate.h"

@protocol CCAutocompleteAddAddressViewDelegate <CCAddAddressTabButtonsDelegate>

#pragma mark - auto completion methods

- (void)autocompleteName:(NSString *)name;

- (NSString *)nameForAutocompletionResultAtIndex:(NSUInteger)index;
- (NSString *)addressForAutocompletionResultAtIndex:(NSUInteger)index;
- (NSUInteger)numberOfAutocompletionResults;

- (void)autocompletionResultSelectedAtIndex:(NSUInteger)index;

@end
