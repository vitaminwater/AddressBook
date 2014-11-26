//
//  CCBaseAutoComplete.h
//  Linotte
//
//  Created by stant on 24/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "CCAutocompleterDelegate.h"

@class CCAddressAutocompletionResult;

@interface CCBaseAutoComplete : NSObject<CLLocationManagerDelegate>

@property(nonatomic, weak)id<CCAutocompleterDelegate> delegate;
@property(nonatomic, strong)CLLocation *currentLocation;

- (void)autocompleteText:(NSString *)addressName;
- (void)stopAutoComplete;

- (void)callWebService:(NSString *)text;

- (void)requestEnded;

- (void)clearResults;
- (void)addResult:(CCAddressAutocompletionResult *)result;
- (NSUInteger)numberOfAutocompletionResults;
- (CCAddressAutocompletionResult *)autocompletionResultAtIndex:(NSUInteger)index;

@end
