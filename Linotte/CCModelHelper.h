//
//  CCModelHelper.h
//  Linotte
//
//  Created by stant on 23/10/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCList;
@class CCAddress;

@interface CCModelHelper : NSObject

+ (void)deleteAddress:(CCAddress *)address;
+ (void)deleteList:(CCList *)list;
+ (CCList *)defaultList;

@end
