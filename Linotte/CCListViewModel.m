//
//  CCListViewModel.m
//  Linotte
//
//  Created by stant on 13/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListViewModel.h"

#import "CCModelChangeMonitor.h"
#import "CCDictStackCache.h"

#import "CCListViewModelProtocol.h"
#import "CCModelChangeMonitorDelegate.h"


@implementation CCListViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _cache = [CCDictStackCache new];
        
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

@end
