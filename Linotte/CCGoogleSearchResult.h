//
//  CCGoogleSearchResult.h
//  AdRem
//
//  Created by stant on 23/01/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCGoogleSearchResult : NSObject

@property(nonatomic, strong)NSString *formattedAddress;
@property(nonatomic, strong)NSNumber *latitude;
@property(nonatomic, strong)NSNumber *longitude;
@property(nonatomic, strong)NSString *icon;
@property(nonatomic, strong)NSString *identifier;
@property(nonatomic, strong)NSString *name;
@property(nonatomic, strong)NSString *reference;
@property(nonatomic, strong)NSArray *types;

@end
