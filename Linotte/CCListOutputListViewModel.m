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
#import "CCAddress.h"

@implementation CCListOutputListViewModel
{
    CCList *_list;
}

@synthesize provider;

- (instancetype)initWithList:(CCList *)list
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

#pragma mark CCModelChangeMonitorDelegate methods

- (void)addressDidAdd:(CCAddress *)address
{
    if ([address.lists containsObject:_list])
        [self.provider addAddress:address];
}

- (void)addressWillRemove:(CCAddress *)address
{
    if ([address.lists containsObject:_list])
        [self.provider removeAddress:address];
}

- (void)addressDidUpdate:(CCAddress *)address
{
    if ([address.lists containsObject:_list])
        [self.provider refreshListItemContentForObject:address];
}

- (void)addressDidUpdateUserData:(CCAddress *)address
{
    if ([address.lists containsObject:_list])
        [self.provider refreshListItemContentForObject:address];
}

- (void)address:(CCAddress *)address didMoveToList:(CCList *)list
{
    if (_list == list)
        [self.provider addAddress:address];
}

- (void)address:(CCAddress *)address didMoveFromList:(CCList *)list
{
    if (_list == list)
        [self.provider removeAddress:address];
}

@end
