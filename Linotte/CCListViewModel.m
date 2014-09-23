//
//  CCListViewModel.m
//  Linotte
//
//  Created by stant on 13/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListViewModel.h"

#import <RestKit/RestKit.h>

#import "CCListViewModelProtocol.h"

@implementation CCListViewModel

- (id)init
{
    self = [super init];
    if (self) {
        if (![[self class] conformsToProtocol:@protocol(CCListViewModelProtocol)]) {
            @throw [NSException exceptionWithName:@"implementation error" reason:@"CCListViewModelProtocol not implemented" userInfo:nil];
        }
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        SEL handleModelChangeSelector = @selector(handleModelChange:);
        if ([self respondsToSelector:handleModelChangeSelector]) {
            NSManagedObjectContext *managedObjectContext = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:handleModelChangeSelector name:NSManagedObjectContextObjectsDidChangeNotification object:managedObjectContext];
        }
#pragma clang diagnostic pop
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
