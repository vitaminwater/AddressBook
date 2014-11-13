//
//  CCServerEventAddressUpdatedConsumer.m
//  Linotte
//
//  Created by stant on 12/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCServerEventAddressUpdatedConsumer.h"

#import "CCServerEventConsumerUtils.h"

@implementation CCServerEventAddressUpdatedConsumer
{
    NSArray *_events;
}

- (BOOL)hasEventsForList:(CCList *)list
{
    _events = [CCServerEventConsumerUtils eventsWithEventType:CCServerEventAddressUpdated list:list];
    return [_events count] != 0;
}

- (void)triggerWithList:(CCList *)list completionBlock:(void(^)())completionBlock
{
    
}

@end
