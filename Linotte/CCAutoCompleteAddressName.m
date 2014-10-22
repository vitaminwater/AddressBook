//
//  CCAutoCompleteAddressName.m
//  Linotte
//
//  Created by stant on 22/10/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCAutoCompleteAddressName.h"

@implementation CCAutoCompleteAddressName

#pragma mark - Singleton method

+ (instancetype)sharedInstance
{
    static id instance = nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        instance = [self new];
    });
    
    return instance;
}

@end
