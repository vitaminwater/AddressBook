//
//  CCModelChangeMonitor.m
//  Linotte
//
//  Created by stant on 23/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCModelChangeMonitor.h"

#import "CCAddress.h"
#import "CCList.h"

#import <objc/runtime.h>


@implementation CCModelChangeMonitor
{
    NSHashTable *_delegates;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _delegates = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return self;
}

- (void)addDelegate:(id<CCModelChangeMonitorDelegate>) delegate
{
    [_delegates addObject:delegate];
}

- (void)removeDelegate:(id<CCModelChangeMonitorDelegate>)delegate
{
    [_delegates removeObject:delegate];
}

#pragma mark - forward

- (void)forwardInvocation:(NSInvocation *)invocation
{
    struct objc_method_description hasMethod = protocol_getMethodDescription(@protocol(CCModelChangeMonitorDelegate), invocation.selector, NO, YES);
    
    if ( hasMethod.name != NULL ) {
        for (__weak id<CCModelChangeMonitorDelegate> delegate in _delegates) {
            if ([delegate respondsToSelector:invocation.selector]) {
                [invocation invokeWithTarget:delegate];
            }
        }
    } else {
        [super forwardInvocation:invocation];
    }
}

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
