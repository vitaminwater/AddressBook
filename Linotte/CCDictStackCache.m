//
//  CCDictCache.m
//  Linotte
//
//  Created by stant on 23/10/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCDictStackCache.h"

@implementation CCDictStackCache
{
    NSMutableDictionary *_cache;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _cache = [@{} mutableCopy];
    }
    return self;
}

- (void)pushCacheEntry:(NSString *)key value:(id)value
{
    _cache[key] = value;
}

- (id)popCacheEntry:(NSString *)key
{
    id value = _cache[key];
    [_cache removeObjectForKey:key];
    return value;
}

@end
