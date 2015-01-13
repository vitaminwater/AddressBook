//
//  CCListItems.h
//  Linotte
//
//  Created by stant on 10/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    CCListItemTypeAddress,
    CCListItemTypeList,
} CCListItemType;

@class CLLocation;
@class CLHeading;

@class CCAddress;
@class CCList;

NSArray *geohashLimit(CLLocation *location, NSUInteger digits);

@interface CCListItem : NSObject

@property(nonatomic, strong, readonly)NSString *name;
@property(nonatomic, strong, readonly)NSString *info;
@property(nonatomic, readonly)BOOL notify;
@property(nonatomic, readonly)BOOL farAway;
@property(nonatomic, readonly, strong)CLLocation *itemLocation;
@property(nonatomic, strong)CLLocation *location;

@property(nonatomic, readonly)CCListItemType type;

- (UIImage *)icon;

- (double)distance;
- (double)angleForHeading:(CLHeading *)heading;
- (void)refreshData;

@end

@interface CCListItemAddress : CCListItem

@property(nonatomic, strong)CCAddress *address;

@end

@interface CCListItemList : CCListItem

@property(nonatomic, strong)CCList *list;

- (BOOL)addAddresses:(NSArray *)addresses;
- (BOOL)removeAddresses:(NSArray *)addresses;

@end
