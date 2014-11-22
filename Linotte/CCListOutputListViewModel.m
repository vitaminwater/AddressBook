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
    [self.provider addAddresses:[_list.addresses allObjects]];
}

#pragma mark CCModelChangeMonitorDelegate methods

- (void)addressesDidUpdate:(NSArray *)addresses send:(BOOL)send
{
    NSArray *addressesToRefresh = [self filterAddresses:addresses];
    if ([addressesToRefresh count] > 0)
        [self.provider refreshListItemContentsForObjects:addressesToRefresh];
}

- (void)addressesDidUpdateUserData:(NSArray *)addresses send:(BOOL)send
{
    NSArray *addressesToRefresh = [self filterAddresses:addresses];
    if ([addressesToRefresh count] > 0)
        [self.provider refreshListItemContentsForObjects:addressesToRefresh];
}

- (void)addresses:(NSArray *)addresses didMoveToList:(CCList *)list send:(BOOL)send
{
    if (_list == list)
        [self.provider addAddresses:addresses];
}

- (void)addresses:(NSArray *)addresses didMoveFromList:(CCList *)list send:(BOOL)send
{
    if (_list == list)
        [self.provider removeAddresses:addresses];
}

#pragma mark - utils methods

- (NSArray *)filterAddresses:(NSArray *)addresses
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY lists = %@", _list];
    return [addresses filteredArrayUsingPredicate:predicate];
}

@end
