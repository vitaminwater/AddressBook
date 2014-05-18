//
//  CCOAuthTokenRequest.h
//  AdRem
//
//  Created by stant on 16/04/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCOAuthTokenRequest : NSObject

@property(nonatomic, strong)NSString *clientId;
@property(nonatomic, strong)NSString *clientSecret;
@property(nonatomic, strong)NSString *grantType;
@property(nonatomic, strong)NSString *scope;

@property(nonatomic, strong)NSString *refreshToken;

@property(nonatomic, strong)NSString *username;
@property(nonatomic, strong)NSString *password;

@end
