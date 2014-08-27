//
//  CCUserCreateRequest.h
//  AdRem
//
//  Created by stant on 16/04/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCUserPostPutRequest : NSObject

@property(nonatomic, strong)NSString *password;
@property(nonatomic, strong)NSString *username;
@property(nonatomic, strong)NSString *firstName;
@property(nonatomic, strong)NSString *lastName;
@property(nonatomic, strong)NSString *email;
@property(nonatomic, assign)NSNumber *isClean;

@end
