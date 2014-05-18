//
//  CCOAuthTokenResponse.h
//  AdRem
//
//  Created by stant on 16/04/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCOAuthTokenResponse : NSObject

@property(nonatomic, strong)NSString *accessToken;
@property(nonatomic, strong)NSString *refreshToken;

@end
