//
//  CCServerEventConsumerProtocol.h
//  Linotte
//
//  Created by stant on 12/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCList;

@protocol CCServerEventConsumerProtocol <NSObject>

- (BOOL)hasEventsForList:(CCList *)list;
- (void)triggerWithList:(CCList *)list completionBlock:(void(^)(BOOL goOnSyncing))completionBlock;

@end
