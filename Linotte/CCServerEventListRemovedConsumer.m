//
//  CCServerEventListRemovedConsumer.m
//  Linotte
//
//  Created by stant on 20/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCServerEventListRemovedConsumer.h"

#import "CCCoreDataStack.h"
#import "CCModelChangeMonitor.h"

#import "CCList.h"

@implementation CCServerEventListRemovedConsumer
{
    NSArray *_events;
}

@dynamic event;

- (CCServerEventEvent)event
{
    return CCServerEventListRemoved;
}

- (BOOL)hasEventsForList:(CCList *)list
{
    _events = [CCServerEvent eventsWithEventType:[self event] list:list];
    return [_events count] != 0;
}

- (void)triggerWithList:(CCList *)list completionBlock:(void(^)(BOOL goOnSyncing))completionBlock
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    NSArray *identifiers = [_events valueForKeyPath:@"@distrinctUnionOfObejcts.objectIdentifier"];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCList entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier in %@", identifiers];
    [fetchRequest setPredicate:predicate];
    NSArray *lists = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        CCLog(@"%@", error);
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(NO);
        });
        return;
    }
    
    for (CCList *list in lists) {
        NSString *identifier = [list.identifier copy];
        [[CCModelChangeMonitor sharedInstance] listWillRemove:list send:NO];
        [managedObjectContext deleteObject:list];
        [[CCModelChangeMonitor sharedInstance] listDidRemove:identifier send:NO];
    }
    
    [CCServerEvent deleteEvents:_events];
    _events = nil;
    
    [[CCCoreDataStack sharedInstance] saveContext];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        completionBlock(YES);
    });
}

@end
