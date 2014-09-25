//
//  CCListViewModel.m
//  Linotte
//
//  Created by stant on 13/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListViewModel.h"

#import <RestKit/RestKit.h>

#import "CCModelChangeMonitor.h"

#import "CCListViewModelProtocol.h"
#import "CCModelChangeMonitorDelegate.h"

@implementation CCListViewModel

- (id)init
{
    self = [super init];
    if (self) {
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
