//
//  CCAddressTableViewDataSourceDelegate.h
//  Linotte
//
//  Created by stant on 10/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCListItems.h"

#import "CCListViewModelProtocol.h"

@class CCListViewModel;

@class CLLocation;
@class CLHeading;

@interface CCListViewContentProvider : NSObject

@property(nonatomic, strong)id<CCListViewModelProtocol> model;
@property(nonatomic, strong)CLLocation *currentLocation;
@property(nonatomic, strong)CLHeading *currentHeading;

- (id)initWithModel:(CCListViewModel<CCListViewModelProtocol> *)model;

- (void)deleteItemAtIndex:(NSUInteger)index;

- (void)emptyListItems;
- (void)resortListItems;

- (CCListItemType)listItemTypeAtIndex:(NSUInteger)index;

- (NSUInteger)addAddress:(CCAddress *)address;
- (NSUInteger)removeAddress:(CCAddress *)address;
- (NSIndexSet *)removeAddresses:(NSArray *)addresses;
- (NSUInteger)addList:(CCList *)list;
- (NSUInteger)removeList:(CCList *)list;

- (id)listItemContentAtIndex:(NSUInteger)index;
- (NSUInteger)indexOfListItemContent:(id)content;

- (double)distanceForListItemAtIndex:(NSUInteger)index;
- (double)angleForListItemAtIndex:(NSUInteger)index;
- (UIImage *)iconFormListItemAtIndex:(NSUInteger)index;
- (NSString *)nameForListItemAtIndex:(NSUInteger)index;
- (NSUInteger)numberOfListItems;

@end
