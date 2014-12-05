//
//  CCServerEventAddressAddedToListConsumer.m
//  Linotte
//
//  Created by stant on 12/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCServerEventAddressAddedToListConsumer.h"

#import "CCModelChangeMonitor.h"
#import "CCCoreDataStack.h"
#import "CCLinotteAPI.h"

#import "CCServerEvent.h"
#import "CCAddress.h"
#import "CCAddressMeta.h"
#import "CCList.h"

@implementation CCServerEventAddressAddedToListConsumer
{
    NSArray *_events;
    
    CCList *_currentList;
    NSURLSessionTask *_currentConnection;
}

@dynamic event;

- (CCServerEventEvent)event
{
    return CCServerEventAddressAddedToList;
}

- (BOOL)hasEventsForList:(CCList *)list
{
    _events = [CCServerEvent eventsWithEventType:[self event] list:list];
    return [_events count] != 0;
}

- (void)triggerWithList:(CCList *)list completionBlock:(void(^)(BOOL goOnSyncing, BOOL error))completionBlock
{
    NSArray *addressIdentifiers = [_events valueForKeyPath:@"@unionOfObjects.objectIdentifier"];
    
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY lists = %@ and identifier in %@", list, addressIdentifiers];
    [fetchRequest setPredicate:predicate];
    NSArray *alreadyInstalledAddresses = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        CCLog(@"%@", error);
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(NO, NO);
        });
        return;
    }
    
    NSArray *alreadyInstalledAddressIdentifiers = [alreadyInstalledAddresses valueForKeyPath:@"@unionOfObjects.identifier"];
    
    NSPredicate *eventFilter = [NSPredicate predicateWithFormat:@"not (objectIdentifier in %@)", alreadyInstalledAddressIdentifiers];
    NSArray *events = [_events filteredArrayUsingPredicate:eventFilter];
    NSArray *eventIds = [events valueForKeyPath:@"@unionOfObjects.eventId"];
    
    NSMutableArray *addressesToAdd = [@[] mutableCopy];
    [addressesToAdd addObjectsFromArray:alreadyInstalledAddresses];
    
    _currentList = list;
    _currentConnection = [[CCLinotteAPI sharedInstance] fetchAddressesForEventIds:eventIds list:list.identifier completionBlock:^(BOOL success, NSArray *addressesDicts) {
        
        _currentList = nil;
        _currentConnection = nil;
        if (success == NO) {
            completionBlock(NO, YES);
            return;
        }
        
        NSArray *newAddresses = [CCAddress insertInManagedObjectContext:managedObjectContext fromLinotteAPIDictArray:addressesDicts];
        [addressesToAdd addObjectsFromArray:newAddresses];
        
        NSArray *addressDictIdentifiers = [addressesDicts valueForKeyPath:@"@unionOfObjects.identifier"];
        for (CCAddress *address in newAddresses) {
            NSUInteger addressDictIndex = [addressDictIdentifiers indexOfObject:address.identifier];
            
            if (addressDictIndex == NSNotFound)
                continue;
            
            NSDictionary *addressDict = addressesDicts[addressDictIndex];
            NSArray *metaDictArray = addressDict[@"metas"];
            
            NSArray *addressMetas = [CCAddressMeta insertInManagedObjectContext:managedObjectContext fromLinotteAPIDictArray:metaDictArray];
            [list addAddressMetas:[NSSet setWithArray:addressMetas]];
            [address addMetas:[NSSet setWithArray:addressMetas]];
        }
        
        [[CCModelChangeMonitor sharedInstance] addresses:addressesToAdd willMoveToList:list send:NO];
        [list addAddresses:[NSSet setWithArray:addressesToAdd]];

        [CCServerEvent deleteEvents:_events];
        _events = nil;
        
        [[CCCoreDataStack sharedInstance] saveContext];
        [[CCModelChangeMonitor sharedInstance] addresses:addressesToAdd didMoveToList:list send:NO];
        completionBlock(YES, NO);
    }];
}

#pragma mark - CCModelChangeMonitorDelegate

- (void)listWillRemove:(CCList *)list send:(BOOL)send
{
    if (_currentList == list)
        [_currentConnection cancel];
}

@end
