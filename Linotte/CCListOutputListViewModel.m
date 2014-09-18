//
//  CCListOutputListViewModel.m
//  Linotte
//
//  Created by stant on 13/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListOutputListViewModel.h"

@implementation CCListOutputListViewModel

@synthesize provider;

#pragma mark CCListViewModelProtocol methods

- (void)loadListItems
{
    
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
