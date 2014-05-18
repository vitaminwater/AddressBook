//
//  CCGoogleDetailResult.h
//  AdRem
//
//  Created by stant on 30/01/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCGoogleDetailResult : NSObject

@property(nonatomic, strong)NSString *formattedAddress;
@property(nonatomic, strong)NSNumber *latitude;
@property(nonatomic, strong)NSNumber *longitude;

@end
