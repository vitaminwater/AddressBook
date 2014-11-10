    //
    //  CCAddressTableViewDataSourceDelegate.m
//  Linotte
//
//  Created by stant on 10/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListViewContentProvider.h"

#import <CoreLocation/CoreLocation.h>

#import "CCListViewModel.h"

#import "CCListItems.h"

#import "CCList.h"
#import "CCAddress.h"


typedef BOOL(^SearchBlockType)(CCListItem *listItem, NSUInteger idx, BOOL *stop);


@implementation CCListViewContentProvider
{
    NSMutableArray *_listItems;
}

- (instancetype)initWithModel:(id<CCListViewModelProtocol>)model
{
    self = [super init];
    if (self) {
        _model = model;
        _model.provider = self;
        _listItems = [@[] mutableCopy];
        [model loadListItems];
    }
    return self;
}

#pragma mark - data management methods
// TODO clean this fucking mess, public/private etc...

- (void)emptyListItems
{
    _listItems = [@[] mutableCopy];
}

- (void)addAddresses:(NSArray *)addresses
{
    NSMutableArray *addedListItems = [@[] mutableCopy];
    
    for (CCAddress *address in addresses) {
        CCListItemAddress *listItemAddress = [CCListItemAddress new];
        listItemAddress.address = address;
        listItemAddress.location = _currentLocation;
        [addedListItems addObject:listItemAddress];
    }
    [self insertNewListItems:addedListItems];
}

- (void)addAddresses:(NSArray *)addresses toList:(CCList *)list
{
    NSUInteger listItemIndex = [self indexOfListItemContent:list];
    if (listItemIndex == NSNotFound)
        return;
    
    CCListItemList *listItemList = _listItems[listItemIndex];
    [listItemList addAddresses:addresses];
    [_delegate refreshCellsAtIndexes:[NSIndexSet indexSetWithIndex:listItemIndex]];
}

- (void)removeAddresses:(NSArray *)addresses fromList:(CCList *)list
{
    NSUInteger listItemIndex = [self indexOfListItemContent:list];
    if (listItemIndex == NSNotFound)
        return;
    
    CCListItemList *listItemList = _listItems[listItemIndex];
    [listItemList removeAddresses:addresses];
    [_delegate refreshCellsAtIndexes:[NSIndexSet indexSetWithIndex:listItemIndex]];
}

- (void)removeAddresses:(NSArray *)addresses
{
    NSIndexSet *toDelete = [_listItems indexesOfObjectsPassingTest:^BOOL(CCListItem *listItem, NSUInteger idx, BOOL *stop) {
        if (listItem.type == CCListItemTypeAddress && [addresses containsObject:((CCListItemAddress *)listItem).address])
            return YES;
        return NO;
    }];
    [_listItems removeObjectsAtIndexes:toDelete];
    [_delegate removeCellsAtIndexes:toDelete];
}

- (void)addList:(CCList *)list
{
    CCListItemList *listItemList = [CCListItemList new];
    listItemList.list = list;
    listItemList.location = _currentLocation;
    [self insertNewListItems:@[listItemList]];
}

- (void)removeList:(CCList *)list
{
    NSUInteger index = [_listItems indexOfObjectPassingTest:^BOOL(CCListItem *listItem, NSUInteger idx, BOOL *stop) {
        return listItem.type == CCListItemTypeList && ((CCListItemList *)listItem).list == list;
    }];
    if (index == NSNotFound)
        return;
    [_listItems removeObjectAtIndex:index];
    [_delegate removeCellsAtIndexes:[NSIndexSet indexSetWithIndex:index]];
    return;
}

// TODO check for order change
- (void)refreshListItemContentsForObjects:(NSArray *)objects
{
    NSIndexSet *indexes = [self indexesOfListItemContents:objects handler:^void(CCListItem *listItem) {
        [listItem refreshData];
    }];
    [_delegate refreshCellsAtIndexes:indexes];
}

- (void)refreshListItemContentForObject:(id)object

{
    NSUInteger index = [self indexOfListItemContent:object];
    if (index == NSNotFound)
        return;
    [_delegate refreshCellsAtIndexes:[NSIndexSet indexSetWithIndex:index]];
}

- (NSIndexSet *)insertNewListItems:(NSArray *)listItems
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet new];
    for (CCListItem *listItem in listItems) {
        NSUInteger newIndex = [_listItems indexOfObject:listItem
                                          inSortedRange:(NSRange){0, [_listItems count]}
                                                options:NSBinarySearchingInsertionIndex
                                        usingComparator:[self sortBlock]];
        NSUInteger indexForIndexSet = newIndex;
        while ([indexSet containsIndex:indexForIndexSet])
            indexForIndexSet++;
        [indexSet addIndex:indexForIndexSet];
        [_listItems insertObject:listItem atIndex:newIndex];
    }
    [_delegate insertCellsAtIndexes:indexSet];
    return [indexSet copy];
}

- (void)deleteItemAtIndex:(NSUInteger)index
{
    CCListItem *listItem = _listItems[index];
    [_listItems removeObject:listItem];
    [_delegate removeCellsAtIndexes:[NSIndexSet indexSetWithIndex:index]];
}

- (CCListItemType)listItemTypeAtIndex:(NSUInteger)index
{
    CCListItem *listItem = _listItems[index];
    return listItem.type;
}

- (id)listItemContentAtIndex:(NSUInteger)index
{
    CCListItem *listItem = _listItems[index];
    if (listItem.type == CCListItemTypeAddress)
        return ((CCListItemAddress *)listItem).address;
    else
        return ((CCListItemList *)listItem).list;
}

- (NSIndexSet *)indexesOfListItemContents:(NSArray *)contents handler:(SearchHandlerBlockType)handler
{
    NSMutableArray *mutableContents = [contents mutableCopy];
    
    return [_listItems indexesOfObjectsPassingTest:^BOOL(CCListItem *listItem, NSUInteger idx, BOOL *stop) {
        for (id content in contents) {
            SearchBlockType searchBlock = [self listItemContentSearchBlock:content];
            if (searchBlock(listItem, idx, stop)) {
                handler(listItem);
                [mutableContents removeObject:content];
                return YES;
            }
        }
        return NO;
    }];
}

- (NSUInteger)indexOfListItemContent:(id)content
{
    SearchBlockType searchBlock = [self listItemContentSearchBlock:content];
    
    return [_listItems indexOfObjectPassingTest:searchBlock];
}

- (SearchBlockType)listItemContentSearchBlock:(id)content
{
    CCListItemType contentType = [content isKindOfClass:[CCAddress class]] ? CCListItemTypeAddress : CCListItemTypeList;
    if (contentType == CCListItemTypeAddress) {
        return ^BOOL(CCListItem *listItem, NSUInteger idx, BOOL *stop) {
            if (listItem.type == CCListItemTypeAddress && ((CCListItemAddress *)listItem).address == content) {
                *stop = YES;
                return YES;
            }
            return NO;
        };
    } else {
        return ^BOOL(CCListItem *listItem, NSUInteger idx, BOOL *stop) {
            if ([content isKindOfClass:[CCList class]] && listItem.type == CCListItemTypeList && ((CCListItemList *)listItem).list == content) {
                *stop = YES;
                return YES;
            }
            return NO;
        };
    }
}

- (void)resortListItems
{
    [_listItems sortUsingComparator:[self sortBlock]];
}

#pragma mark -

- (double)distanceForListItemAtIndex:(NSUInteger)index
{
    if (_currentLocation) {
        CCListItem *listItem = _listItems[index];
        return [listItem distance];
    }
    return -1;
}

- (double)angleForListItemAtIndex:(NSUInteger)index
{
    if (_currentLocation) {
        CCListItem *listItem = _listItems[index];
        return [listItem angleForHeading:_currentHeading];
    }
    return 0;
}

- (UIImage *)iconFormListItemAtIndex:(NSUInteger)index
{
    CCListItem *listItem = _listItems[index];
    return [listItem icon];
}

- (NSString *)nameForListItemAtIndex:(NSUInteger)index
{
    CCListItem *listItem = _listItems[index];
    return listItem.name;
}

- (NSString *)infoForListItemAtIndex:(NSUInteger)index
{
    CCListItem *listItem = _listItems[index];
    return listItem.info;
}

- (BOOL)notificationEnabledForListItemAtIndex:(NSUInteger)index
{
    CCListItem *listItem = _listItems[index];
    return listItem.notify;
}

- (BOOL)orientationAvailableAtIndex:(NSUInteger)index
{
    CCListItem *listItem = _listItems[index];
    
    if (listItem.type == CCListItemTypeList)
        return !listItem.farAway;
    return YES;
}

- (NSUInteger)numberOfListItems
{
    return [_listItems count];
}

#pragma mark - setter methods

- (void)setCurrentLocation:(CLLocation *)currentLocation
{
    if (_currentLocation != nil && [_currentLocation distanceFromLocation:currentLocation] < 10) {
        return;
    }
    
    _currentLocation = currentLocation;
    
    for (CCListItem *listItem in _listItems) {
        listItem.location = _currentLocation;
    }
    [self resortListItems];
}

#pragma mark - sort methods

- (NSComparisonResult)nameSortMethod:(CCListItem *)obj1 obj2:(CCListItem *)obj2
{
    return [obj1.name compare:obj2.name options:NSCaseInsensitiveSearch];
}

- (NSComparisonResult)distanceSortMethod:(CCListItem *)obj1 obj2:(CCListItem *)obj2
{
    double distance1 = [obj1 distance];
    double distance2 = [obj2 distance];
    
    return [@(distance1) compare:@(distance2)];
}

- (NSComparisonResult(^)(CCListItem *obj1, CCListItem *obj2))sortBlock
{
    return ^NSComparisonResult(CCListItem *obj1, CCListItem *obj2) {
        if (_currentLocation == nil)
            return [self nameSortMethod:obj1 obj2:obj2];
        if (obj1.farAway == NO && obj2.farAway == NO)
            return [self distanceSortMethod:obj1 obj2:obj2];
        else if (obj1.farAway == YES && obj2.farAway == YES)
            return [self nameSortMethod:obj1 obj2:obj2];
        else if (obj1.farAway == NO && obj2.farAway == YES)
            return NSOrderedAscending;
        else
            return NSOrderedDescending;
    };
}

@end
