//
//  CCListViewDelegate.h
//  Linotte
//
//  Created by stant on 06/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCListViewDelegate <NSObject>

- (void)didSelectAddressAtIndex:(NSUInteger)index color:(NSString *)color;
- (void)deleteAddressAtIndex:(NSUInteger)index;

- (double)distanceForAddressAtIndex:(NSUInteger)index;
- (double)angleForAddressAtIndex:(NSUInteger)index;
- (NSString *)nameForAddressAtIndex:(NSUInteger)index;
- (NSString *)addressForAddressAtIndex:(NSUInteger)index;
- (NSDate *)lastNotifForAddressAtIndex:(NSUInteger)index;
- (NSUInteger)numberOfAddresses;

@end
