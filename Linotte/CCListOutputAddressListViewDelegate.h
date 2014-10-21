//
//  CCListOutputAddressListViewDelegate.h
//  Linotte
//
//  Created by stant on 25/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCListOutputAddressListViewDelegate <NSObject>

- (void)filterAddresses:(NSString *)filterString;

- (void)closePressed;

- (void)addressAddedAtIndex:(NSUInteger)index;
- (void)addressUnaddedAtIndex:(NSUInteger)index;

- (BOOL)addressIsAddedAtIndex:(NSUInteger)index;
- (NSString *)nameForAddressAtIndex:(NSUInteger)index;
- (NSString *)addressForAddressAtIndex:(NSUInteger)index;
- (NSUInteger)numberOfAddresses;

@end
