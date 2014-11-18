//
//  CCSynchronizationActionConsumeEvents.h
//  Linotte
//
//  Created by stant on 10/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CCSynchronizationActionProtocol.h"

#import "CCModelChangeMonitorDelegate.h"

/**
 * This is an experiment, only to be implemented by subclasses
 * this is going to be stored in a __weak attribute !!
 */
@protocol CCSynchronizationActionConsumeEventsProviderProtocol <NSObject>

- (NSArray *)consumers;
- (CCList *)findNextListToProcess;
- (NSArray *)eventsList;
- (void)fetchServerEventsWithList:(CCList *)list completionBlock:(void(^)(BOOL goOnSyncing))completionBlock;

@end

@interface CCBaseSynchronizationActionConsumeEvents : NSObject<CCModelChangeMonitorDelegate, CCSynchronizationActionProtocol>

- (instancetype)initWithProvider:(id<CCSynchronizationActionConsumeEventsProviderProtocol>)provider;

@end
