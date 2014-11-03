//
//  CCAddressTableViewDataSourceDelegate.h
//  Linotte
//
//  Created by stant on 10/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCListItems.h"

#import "CCListViewContentProviderDelegate.h"

#import "CCListViewModelProtocol.h"

@class CCListViewModel;

@class CLLocation;
@class CLHeading;

typedef void(^SearchHandlerBlockType)(CCListItem *listItem);

@interface CCListViewContentProvider : NSObject

@property(nonatomic, strong)id<CCListViewModelProtocol> model;
@property(nonatomic, strong)CLLocation *currentLocation;
@property(nonatomic, strong)CLHeading *currentHeading;

@property(nonatomic, assign)id<CCListViewContentProviderDelegate> delegate;

- (instancetype)initWithModel:(CCListViewModel<CCListViewModelProtocol> *)model;

- (void)deleteItemAtIndex:(NSUInteger)index;

- (void)emptyListItems;
- (void)resortListItems;

- (CCListItemType)listItemTypeAtIndex:(NSUInteger)index;

- (NSUInteger)addAddress:(CCAddress *)address;
- (void)addAddress:(CCAddress *)address toList:(CCList *)list;
- (NSUInteger)removeAddress:(CCAddress *)address;
- (void)removeAddress:(CCAddress *)address fromList:(CCList *)list;
- (NSIndexSet *)removeAddresses:(NSArray *)addresses;
- (NSUInteger)addList:(CCList *)list;
- (NSUInteger)removeList:(CCList *)list;

- (void)refreshListItemContentsForObjects:(NSArray *)objects;
- (void)refreshListItemContentForObject:(id)object;

- (id)listItemContentAtIndex:(NSUInteger)index;
- (NSIndexSet *)indexesOfListItemContents:(NSArray *)contents handler:(SearchHandlerBlockType)handler;
- (NSUInteger)indexOfListItemContent:(id)content;

- (double)distanceForListItemAtIndex:(NSUInteger)index;
- (double)angleForListItemAtIndex:(NSUInteger)index;
- (UIImage *)iconFormListItemAtIndex:(NSUInteger)index;
- (NSString *)nameForListItemAtIndex:(NSUInteger)index;
- (NSString *)infoForListItemAtIndex:(NSUInteger)index;
- (BOOL)notificationEnabledForListItemAtIndex:(NSUInteger)index;
- (BOOL)orientationAvailableAtIndex:(NSUInteger)index;
- (NSUInteger)numberOfListItems;

@end
