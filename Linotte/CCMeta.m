//
//  CCMeta.m
//  Linotte
//
//  Created by stant on 27/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCMeta.h"

@implementation CCMeta

@synthesize action = _action;
@synthesize uid = _uid;
@synthesize content = _content;

- (instancetype)initWithAction:(NSString *)action uid:(NSString *)uid content:(NSDictionary *)content
{
    self = [super init];
    if (self) {
        _action = action;
        _uid = uid;
        _content = content;
    }
    return self;
}

+ (instancetype)metaWithAction:(NSString *)action uid:(NSString *)uid content:(NSDictionary *)content
{
    return [[self alloc] initWithAction:action uid:uid content:content];
}

@end
