//
//  CCListViewModel.h
//  Linotte
//
//  Created by stant on 13/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CCListViewModel : NSObject

- (void)pushCacheEntry:(NSString *)key value:(id)value;
- (id)popCacheEntry:(NSString *)key;

@end
