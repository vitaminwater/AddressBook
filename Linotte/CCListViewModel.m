//
//  CCListViewModel.m
//  Linotte
//
//  Created by stant on 13/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListViewModel.h"

#import "CCModelChangeMonitor.h"

#import "CCListViewModelProtocol.h"
#import "CCModelChangeMonitorDelegate.h"

@implementation CCListViewModel
{
    NSMutableDictionary *_cache;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _cache = [@{} mutableCopy];
        
        if (![[self class] conformsToProtocol:@protocol(CCListViewModelProtocol)]) {
            @throw [NSException exceptionWithName:@"implementation error" reason:@"CCListViewModelProtocol not implemented" userInfo:nil];
        }
        
        if ([[self class] conformsToProtocol:@protocol(CCModelChangeMonitorDelegate)]) {
            [[CCModelChangeMonitor sharedInstance] addDelegate:(id<CCModelChangeMonitorDelegate>)self];
        }
    }
    return self;
}

- (void)dealloc
{
    [[CCModelChangeMonitor sharedInstance] removeDelegate:(id<CCModelChangeMonitorDelegate>)self];
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
