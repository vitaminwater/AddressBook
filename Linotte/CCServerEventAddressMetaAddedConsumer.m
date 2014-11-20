//
//  CCServerEventAddressMetaAddedConsumer.m
//  Linotte
//
//  Created by stant on 12/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCServerEventAddressMetaAddedConsumer.h"

#import "CCLinotteAPI.h"
#import "CCModelChangeMonitor.h"
#import "CCCoreDataStack.h"

#import "CCServerEvent.h"
#import "CCAddressMeta.h"
#import "CCAddress.h"
#import "CCList.h"

@implementation CCServerEventAddressMetaAddedConsumer
{
    NSArray *_events;
    
    CCList *_currentList;
    NSURLSessionTask *_currentConnection;
}

@dynamic event;

- (CCServerEventEvent)event
{
    return CCServerEventAddressMetaAdded;
}

- (BOOL)hasEventsForList:(CCList *)list
{
    _events = [CCServerEvent eventsWithEventType:[self event] list:list];
    return [_events count] != 0;
}

- (void)triggerWithList:(CCList *)list completionBlock:(void(^)(BOOL goOnSyncing))completionBlock
{
    NSArray *eventIds = [_events valueForKeyPath:@"@unionOfObjects.eventId"];
    _currentList = list;
    _currentConnection = [[CCLinotteAPI sharedInstance] fetchAddressMetasForEventIds:eventIds completionBlock:^(BOOL success, NSArray *addressMetaDicts) {
        
        _currentList = nil;
        _currentConnection = nil;
        if (success == NO) {
            completionBlock(NO);
            return;
        }
        
        NSError *error = nil;
        NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
        NSSortDescriptor *objectIdentifier2SortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"objectIdentifier2" ascending:YES];
        NSArray *sortedAddressMetasDict = [addressMetaDicts sortedArrayUsingDescriptors:@[objectIdentifier2SortDescriptor]];
        NSArray *addressIdentifiers = [sortedAddressMetasDict valueForKeyPath:@"objectIdentifier2"];
        NSArray *addressMetas = [CCAddressMeta insertInManagedObjectContext:managedObjectContext fromLinotteAPIDictArray:sortedAddressMetasDict];
        
        NSSortDescriptor *identifierSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES];
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY lists = %@ and identifier in %@", list, addressIdentifiers];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setSortDescriptors:@[identifierSortDescriptor]];
        NSArray *addresses = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if (error != nil) {
            CCLog(@"%@", error);
            completionBlock(NO);
            return;
        }
        
        NSUInteger index = 0;
        for (CCAddress *address in addresses) {
            for (; index < [addressMetas count]; ++index) {
                if ([addressIdentifiers[index] isEqualToString:address.identifier] == NO)
                    break;
                CCAddressMeta *addressMeta = addressMetas[index];
                [list addAddressMetasObject:addressMeta];
                [address addMetasObject:addressMeta];
            }
        }
        
        [CCServerEvent deleteEvents:_events];
        _events = nil;

        [[CCCoreDataStack sharedInstance] saveContext];
        [[CCModelChangeMonitor sharedInstance] addressMetasAdd:addressMetas];
        completionBlock(YES);
    }];
}

#pragma mark - CCModelChangeMonitorDelegate

- (void)listWillRemove:(CCList *)list send:(BOOL)send
{
    if (_currentList == list)
        [_currentConnection cancel];
}

@end
