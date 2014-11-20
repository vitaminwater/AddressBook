//
//  CCServerEventConsumerProtocol.h
//  Linotte
//
//  Created by stant on 12/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CCServerEvent.h"

@class CCList;

@protocol CCServerEventConsumerProtocol <NSObject>

@property(nonatomic, readonly)CCServerEventEvent event;

- (BOOL)hasEventsForList:(CCList *)list;
- (void)triggerWithList:(CCList *)list completionBlock:(void(^)(BOOL goOnSyncing))completionBlock;

@end
