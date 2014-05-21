//
//  CCFoursquareVenues.h
//  AdRem
//
//  Created by stant on 30/01/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCFoursquareVenues : NSObject

@property(nonatomic, strong)NSString *name;
@property(nonatomic, strong)NSNumber *latitude;
@property(nonatomic, strong)NSNumber *longitude;
@property(nonatomic, strong)NSString *address;
@property(nonatomic, strong)NSString *city;
@property(nonatomic, strong)NSString *country;
@property(nonatomic, strong)NSArray *categories;

@end
