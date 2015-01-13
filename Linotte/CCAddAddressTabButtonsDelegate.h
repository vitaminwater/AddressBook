//
//  CCAddAddressTabButtonsDelegate.h
//  Linotte
//
//  Created by stant on 06/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    CCAddAddressByNameType = 0,
    CCAddAddressByAddressType = 1,
    CCAddAddressAtLocationType = 2,
} CCAddAddressType;

@protocol CCAddAddressTabButtonsDelegate <NSObject>

- (void)addAddressTypeChangedTo:(CCAddAddressType)addAddressType;

@end
