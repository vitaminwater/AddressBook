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

@interface CCListViewContentProvider()

@property(nonatomic, strong)NSMutableArray *listItems;

@end

@implementation CCListViewContentProvider

- (id)initWithModel:(CCListViewModel<CCListViewModelProtocol> *)model
{
    self = [super init];
    if (self) {
        _model = model;
        _listItems = [@[] mutableCopy];
        [model loadListItems:self];
    }
    return self;
}

#pragma mark - data management methods

- (void)emptyListItems
{
    _listItems = [@[] mutableCopy];
}

- (NSUInteger)addAddress:(CCAddress *)address
{
    CCListItemAddress *listItemAddress = [CCListItemAddress new];
    listItemAddress.address = address;
    listItemAddress.currentLocation = _currentLocation;

    return [self insertNewListItem:listItemAddress];
}

- (NSUInteger)removeAddress:(CCAddress *)address
{
    NSUInteger index = [_listItems indexOfObjectPassingTest:^BOOL(CCListItem *listItem, NSUInteger idx, BOOL *stop) {
        return listItem.type == CCListItemTypeAddress && ((CCListItemAddress *)listItem).address == address;
    }];
    [_listItems removeObjectAtIndex:index];
    return index;
}

- (NSIndexSet *)removeAddresses:(NSArray *)addresses
{
    NSIndexSet *toDelete = [_listItems indexesOfObjectsPassingTest:^BOOL(CCListItem *listItem, NSUInteger idx, BOOL *stop) {
        if (listItem.type == CCListItemTypeAddress && [addresses containsObject:((CCListItemAddress *)listItem).address])
            return YES;
        return NO;
    }];
    [_listItems removeObjectsAtIndexes:toDelete];
    return toDelete;
}

- (NSUInteger)addList:(CCList *)list
{
    CCListItemList *listItemList = [CCListItemList new];
    listItemList.list = list;
    listItemList.currentLocation = _currentLocation;
    
    return [self insertNewListItem:listItemList];
}

- (NSUInteger)removeList:(CCList *)list
{
    NSUInteger index = [_listItems indexOfObjectPassingTest:^BOOL(CCListItem *listItem, NSUInteger idx, BOOL *stop) {
        return listItem.type == CCListItemTypeList && ((CCListItemList *)listItem).list == list;
    }];
    [_listItems removeObjectAtIndex:index];
    return index;
}

- (NSUInteger)insertNewListItem:(CCListItem *)listItem
{
    NSUInteger newIndex = [_listItems indexOfObject:listItem
                                      inSortedRange:(NSRange){0, [_listItems count]}
                                            options:NSBinarySearchingInsertionIndex
                                    usingComparator:[self sortBlock]];
    
    [_listItems insertObject:listItem atIndex:newIndex];
    return newIndex;
}

- (void)deleteItemAtIndex:(NSUInteger)index
{
    CCListItem *listItem = _listItems[index];
    [_listItems removeObject:listItem];
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

- (void)resortListItems:(void (^)())complete
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        for (CCListItem *listItem in _listItems) {
            listItem.currentLocation = _currentLocation;
        }
        
        [_listItems sortUsingComparator:[self sortBlock]];
        
        if (complete)
            dispatch_sync(dispatch_get_main_queue(), complete);
    });
}

#pragma mark -

- (double)distanceForListItemAtIndex:(NSUInteger)index
{
    if (_currentLocation) {
        CCListItem *listItem = _listItems[index];
        return [listItem distanceFromLocation:_currentLocation];
    }
    return -1;
}

- (double)angleForListItemAtIndex:(NSUInteger)index
{
    if (_currentLocation) {
        CCListItem *listItem = _listItems[index];
        return [listItem angleFromLocation:_currentLocation heading:_currentHeading];
    }
    return 0;
}

- (NSString *)nameForListItemAtIndex:(NSUInteger)index
{
    CCListItem *listItem = _listItems[index];
    return listItem.name;
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
}

#pragma mark - sort methods

- (NSComparisonResult)nameSortMethod:(CCListItem *)obj1 obj2:(CCListItem *)obj2
{
    return [obj1.name compare:obj2.name options:NSCaseInsensitiveSearch];
}

- (NSComparisonResult)distanceSortMethod:(CCListItem *)obj1 obj2:(CCListItem *)obj2
{
    double distance1 = [obj1 distanceFromLocation:_currentLocation];
    double distance2 = [obj2 distanceFromLocation:_currentLocation];
    
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
