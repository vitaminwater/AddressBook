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

#import "CCServerEvent.h"
#import "CCAddressMeta.h"

@implementation CCServerEventAddressMetaDeletedConsumer
{
    NSArray *_events;
}

- (BOOL)hasEventsForList:(CCList *)list
{
    _events = [CCServerEvent eventsWithEventType:CCServerEventAddressMetaDeleted list:list];
    return [_events count] != 0;
}

- (void)triggerWithList:(CCList *)list completionBlock:(void(^)(BOOL goOnSyncing))completionBlock
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    NSArray *identifiers = [_events valueForKeyPath:@"@distrinctUnionOfObejcts.objectIdentifier"];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddressMeta entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier in %@", identifiers];
    [fetchRequest setPredicate:predicate];
    NSArray *metas = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    
    [[CCModelChangeMonitor sharedInstance] addressMetasRemove:metas];
    for (CCAddressMeta *meta in metas) {
        [managedObjectContext deleteObject:meta];
    }
    
    [CCServerEvent deleteEvents:_events];
    _events = nil;
    
    [[CCCoreDataStack sharedInstance] saveContext];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        completionBlock(YES);
    });
}

@end
