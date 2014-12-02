//
//  CCAddAddressViewDelegate.h
//  Linotte
//
//  Created by stant on 01/12/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    CCAddAddressByNameType = 0,
    CCAddAddressByAddressType = 1,
    CCAddAddressAtLocationType = 2,
} CCAddAddressType;

@protocol CCAddAddressViewDelegate <NSObject>

- (void)addAddressTypeChangedTo:(CCAddAddressType)addAddressType;

@end
