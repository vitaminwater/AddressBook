//
//  CCAutoCompleteAddressName.h
//  Linotte
//
//  Created by stant on 22/10/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

#import "CCAddressNameAutocompleterDelegate.h"

/**
 * Address storage class
 */

@interface CCAddViewAutocompletionResultCategorie : NSObject

@property(nonatomic, strong)NSString *identifier;
@property(nonatomic, strong)NSString *name;

@end

/***************/

@interface CCAddViewAutocompletionResult : NSObject

@property(nonatomic, strong)NSString *address;
@property(nonatomic, strong)NSString *name;
@property(nonatomic, strong)NSString *provider;
@property(nonatomic, strong)NSString *providerId;

@property(nonatomic, strong)NSArray *categories;

@property(nonatomic, assign)CLLocationCoordinate2D coordinates;

@end

/***************/

@interface CCAddressNameAutoCompleter : NSObject<CLLocationManagerDelegate>

@property(nonatomic, assign)id<CCAddressNameAutocompleterDelegate> delegate;

- (void)autocompleteAddressName:(NSString *)addressName;
- (void)stopAutoComplete;

- (NSUInteger)numberOfAutocompletionResults;
- (CCAddViewAutocompletionResult *)autocompletionResultAtIndex:(NSUInteger)index;

@end
