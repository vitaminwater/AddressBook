//
//  CCServerEventListUpdateConsumer.m
//  Linotte
//
//  Created by stant on 12/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCServerEventListUpdatedConsumer.h"

#import "CCLinotteAPI.h"
#import "CCModelChangeMonitor.h"
#import "CCCoreDataStack.h"

#import "CCServerEventConsumerUtils.h"

#import "CCList.h"

@implementation CCServerEventListUpdatedConsumer
{
    NSArray *_events;
}

- (BOOL)hasEventsForList:(CCList *)list
{
    _events = [CCServerEventConsumerUtils eventsWithEventType:CCServerEventListUpdated list:list];
    return [_events count] != 0;
}

- (void)triggerWithList:(CCList *)list completionBlock:(void(^)())completionBlock
{
    [[CCLinotteAPI sharedInstance] fetchCompleteListInfos:list.identifier completionBlock:^(BOOL success, NSDictionary *listInfo) {
        if (success) {
            NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
            [CCList insertInManagedObjectContext:managedObjectContext fromLinotteAPIDict:listInfo];
            [[CCCoreDataStack sharedInstance] saveContext];
            [[CCModelChangeMonitor sharedInstance] listDidUpdate:list send:NO];
            
            [CCServerEventConsumerUtils deleteEvents:_events];
            _events = nil;
        }
        completionBlock();
    }];
}

@end
