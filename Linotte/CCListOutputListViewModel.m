//
//  CCListOutputListViewModel.m
//  Linotte
//
//  Created by stant on 13/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListOutputListViewModel.h"

#import "CCListViewContentProvider.h"

#import "CCList.h"

@interface CCListOutputListViewModel()

@property(nonatomic, strong)CCList *list;

@end

@implementation CCListOutputListViewModel

@synthesize provider;

- (id)initWithList:(CCList *)list
{
    self = [super init];
    if (self) {
        _list = list;
    }
    return self;
}

#pragma mark CCListViewModelProtocol methods

- (void)loadListItems
{
    for (CCAddress *address in _list.addresses) {
        [self.provider addAddress:address];
    }
}

- (void)expandList:(CCList *)list
{
    
}

- (void)reduceList:(CCList *)list
{
    
}

- (void)addAddress:(CCAddress *)address
{
    
}

- (void)removeAddress:(CCAddress *)address
{
    
}

- (void)addList:(CCList *)list
{
    
}

- (void)removeList:(CCList *)list
{
    
}

- (BOOL)address:(CCAddress *)address movedToList:(CCList *)list;
{
    return NO;
}

- (BOOL)address:(CCAddress *)address movedFromList:(CCList *)list;
{
    return NO;
}

@end
