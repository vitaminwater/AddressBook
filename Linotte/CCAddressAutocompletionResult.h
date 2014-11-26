//
//  CCAddViewAutocompletionResult.h
//  Linotte
//
//  Created by stant on 24/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CCAddressAutocompletionResult : NSObject

@property(nonatomic, strong)NSString *address;
@property(nonatomic, strong)NSString *name;
@property(nonatomic, strong)NSString *provider;
@property(nonatomic, strong)NSString *providerId;

@property(nonatomic, strong)NSArray *categories;

@property(nonatomic, assign)CLLocationCoordinate2D coordinates;

@end