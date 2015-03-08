//
//  CCServerEventAddressMetaDeletedConsumer.m
//  Linotte
//
//  Created by stant on 12/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCServerEventAddressMetaDeletedConsumer.h"

#import "CCLinotteCoreDataStack.h"
#import "CCModelChangeMonitor.h"

#import "CCServerEvent.h"
#import "CCAddressMeta.h"

@implementation CCServerEventAddressMetaDeletedConsumer
{
    NSArray *_events;
}

@dynamic event;

- (CCServerEventEvent)event
{
    return CCServerEventAddressMetaDeleted;
}

- (BOOL)hasEventsForList:(CCList *)list
{
    _events = [CCServerEvent eventsWithEventType:[self event] list:list];
    return [_events count] != 0;
}

- (void)triggerWithList:(CCList *)list completionBlock:(CCSynchronizationCompletionBlock)completionBlock
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    
    NSArray *identifiers = [_events valueForKeyPath:@"@distinctUnionOfObjects.objectIdentifier"];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddressMeta entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier in %@", identifiers];
    [fetchRequest setPredicate:predicate];
    NSArray *metas = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        CCLog(@"%@", error);
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(NO, NO);
        });
        return;
    }
    
    [[CCModelChangeMonitor sharedInstance] addressMetasRemove:metas];
    for (CCAddressMeta *meta in metas) {
        [managedObjectContext deleteObject:meta];
    }
    
    [CCServerEvent deleteEvents:_events];
    _events = nil;
    
    [[CCLinotteCoreDataStack sharedInstance] saveContext];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        completionBlock(YES, NO);
    });
}

@end
