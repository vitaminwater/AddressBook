//
//  CCListViewModel.m
//  Linotte
//
//  Created by stant on 13/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListViewModel.h"

#import "CCListViewModelProtocol.h"

@implementation CCListViewModel

- (id)init
{
    self = [super init];
    if (self) {
        if (![[self class] conformsToProtocol:@protocol(CCListViewModelProtocol)]) {
            @throw [NSException exceptionWithName:@"implementation error" reason:@"CCListViewModelProtocol not implemented" userInfo:nil];
        }
    }
    return self;
}

@end
