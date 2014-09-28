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

#pragma mark CCModelChangeMonitorDelegate methods

- (void)addressRemoved:(CCAddress *)address
{
    if ([address.lists containsObject:_list])
        [self.provider removeAddress:address];
}

- (void)addressUpdated:(CCAddress *)address
{
    if ([address.lists containsObject:_list])
        [self.provider refreshListItemContentForObject:address];
}

- (BOOL)address:(CCAddress *)address didMoveToList:(CCList *)list
{
    if (_list == list)
        [self.provider addAddress:address];
    return NO;
}

- (BOOL)address:(CCAddress *)address didMoveFromList:(CCList *)list
{
    if (_list == list)
        [self.provider removeAddress:address];
    return NO;
}

@end
