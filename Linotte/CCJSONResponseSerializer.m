//
//  CCJSONResponseSerializer.m
//  Linotte
//
//  Created by stant on 18/12/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCJSONResponseSerializer.h"

@implementation CCJSONResponseSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error
{
    id JSONObject = [super responseObjectForResponse:response data:data error:error];
    if (*error != nil) {
        if (JSONObject != nil) {
            NSMutableDictionary *userInfo = [(*error).userInfo mutableCopy];
            userInfo[kCCJSONResponseSerializerWithDataKey] = JSONObject;
            NSError *newError = [NSError errorWithDomain:(*error).domain code:(*error).code userInfo:userInfo];
            (*error) = newError;
        }
    }
    
    return JSONObject;
}

@end
