//
//  CCDictCache.h
//  Linotte
//
//  Created by stant on 23/10/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCDictStackCache : NSObject

- (void)pushCacheEntry:(NSString *)key value:(id)value;
- (id)popCacheEntry:(NSString *)key;

@end
