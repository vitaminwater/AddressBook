//
//  CCServerEventAddressMetaDeletedConsumer.m
//  Linotte
//
//  Created by stant on 12/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCServerEventAddressMetaDeletedConsumer.h"

#import "CCCoreDataStack.h"
#import "CCModelChangeMonitor.h"

#import "CCServerEventConsumerUtils.h"

#import "CCAddressMeta.h"

@implementation CCServerEventAddressMetaDeletedConsumer
{
    NSArray *_events;
}

- (BOOL)hasEventsForList:(CCList *)list
{
    _events = [CCServerEventConsumerUtils eventsWithEventType:CCServerEventAddressMetaDeleted list:list];
    return [_events count] != 0;
}

- (void)triggerWithList:(CCList *)list completionBlock:(void(^)())completionBlock
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    NSArray *identifiers = [_events valueForKeyPath:@"@distrinctUnionOfObejcts.object_identifier"];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddressMeta entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier in %@", identifiers];
    [fetchRequest setPredicate:predicate];
    NSArray *metas = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    
    [[CCModelChangeMonitor sharedInstance] addressMetasRemove:metas];
    for (CCAddressMeta *meta in metas) {
        [managedObjectContext deleteObject:meta];
    }
    
    [[CCCoreDataStack sharedInstance] saveContext];
}

@end
