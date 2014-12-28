//
//  CCNetworkHandler.m
//  Linotte
//
//  Created by stant on 15/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCModelChangeHandler.h"

#import <Mixpanel/Mixpanel.h>

#import "CCLinotteCoreDataStack.h"
#import "CCDictStackCache.h"

#import "CCSynchronizationHandler.h"

#import "CCUserSynchronizationActionConsumeEvents.h"

#import "CCModelChangeMonitor.h"

#import "CCLinotteAPI.h"

#import "CCCurrentUserData.h"
#import "CCLocalEvent.h"
#import "CCAddress.h"
#import "CCAddressMeta.h"
#import "CCList.h"


#define kCCEventChainLength 10

#define kCCLocalEventListRemoveDataCacheKey @"kCCLocalEventListRemoveDataCacheKey"


@implementation CCModelChangeHandler
{
    CCDictStackCache *_cache;
    
    NSTimer *_timer;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _cache = [CCDictStackCache new];
        
        [[CCModelChangeMonitor sharedInstance] addDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [[CCModelChangeMonitor sharedInstance] removeDelegate:self];
}

#pragma mark CCModelChangeMonitorDelegate methods

- (void)listsDidAdd:(NSArray *)lists send:(BOOL)send
{
    if (send == NO)
        return;

    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    
    @try {
        for (CCList *list in lists) {
            CCLocalEvent *listAddEvent = [CCLocalEvent insertInManagedObjectContext:managedObjectContext];
            listAddEvent.date = [NSDate date];
            listAddEvent.localListIdentifier = list.localIdentifier;
            
            if (list.identifier == nil) {
                listAddEvent.eventValue = CCLocalEventListCreated;
                listAddEvent.parameters = @{@"name" : list.name};
            } else {
                listAddEvent.eventValue = CCLocalEventListAdded;
                listAddEvent.parameters = @{@"list" : list.identifier};
            }
        }
        [[CCLinotteCoreDataStack sharedInstance] saveContext];
    }
    @catch(NSException *e) {
        CCLog(@"%@", e);
    }
}

- (void)listsWillRemove:(NSArray *)lists send:(BOOL)send
{
    NSMutableDictionary *removedListsData = [NSMutableDictionary new];
    
    for (CCList *list in lists) {
        @try {
        removedListsData[list.localIdentifier] = list.identifier ?: @"";
        }
        @catch(NSException *e) {
            CCLog(@"%@", e);
        }
    }
    
    [_cache pushCacheEntry:kCCLocalEventListRemoveDataCacheKey value:removedListsData];
}

- (void)listsDidRemove:(NSArray *)identifiers send:(BOOL)send
{
    if (send == NO)
        return;
    
    NSDictionary *removedListsData = [_cache popCacheEntry:kCCLocalEventListRemoveDataCacheKey];
    
    if (removedListsData == nil)
        return;
    
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    
    for (NSString *localIdentifier in removedListsData.allKeys) {
        @try {
            NSString *identifier = removedListsData[localIdentifier];
            CCLocalEvent *listRemoveEvent = [CCLocalEvent insertInManagedObjectContext:managedObjectContext];
            listRemoveEvent.eventValue = CCLocalEventListRemoved;
            listRemoveEvent.date = [NSDate date];
            listRemoveEvent.localListIdentifier = localIdentifier;
            if (identifier != nil && [identifier length] > 0)
                listRemoveEvent.parameters = @{@"list": identifier};
        }
        @catch(NSException *e) {
            CCLog(@"%@", e);
        }
    }
    [[CCLinotteCoreDataStack sharedInstance] saveContext];
}

- (void)listsDidUpdate:(NSArray *)lists send:(BOOL)send
{
    if (send == NO)
        return;

    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    
    for (CCList *list in lists) {
        @try {
            NSDictionary *parameters = @{@"list" : list.identifier ?: @"", @"name" : list.name};
            CCLocalEvent *listUpdateEvent = [CCLocalEvent insertInManagedObjectContext:managedObjectContext];
            listUpdateEvent.eventValue = CCLocalEventListUpdated;
            listUpdateEvent.date = [NSDate date];
            listUpdateEvent.localListIdentifier = list.localIdentifier;
            listUpdateEvent.parameters = parameters;
        }
        @catch(NSException *e) {
            CCLog(@"%@", e);
        }
    }
    [[CCLinotteCoreDataStack sharedInstance] saveContext];
}

- (void)listsDidUpdateUserData:(NSArray *)lists send:(BOOL)send
{
    if (send == NO)
        return;
    
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    
    for (CCList *list in lists) {
        @try {
            NSDictionary *parameters = @{@"list" : list.identifier ?: @"", @"notification" : @(list.notifyValue)};
            CCLocalEvent *listUpdateEvent = [CCLocalEvent insertInManagedObjectContext:managedObjectContext];
            listUpdateEvent.eventValue = CCLocalEventListUserDataUpdated;
            listUpdateEvent.date = [NSDate date];
            listUpdateEvent.localListIdentifier = list.localIdentifier;
            listUpdateEvent.parameters = parameters;
        }
        @catch(NSException *e) {
            CCLog(@"%@", e);
        }
    }
    [[CCLinotteCoreDataStack sharedInstance] saveContext];
}

- (void)addressesDidUpdate:(NSArray *)addresses send:(BOOL)send
{
    if (send == NO)
        return;

    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    
    for (CCAddress *address in addresses) {
        @try {
            NSDictionary *parameters = @{@"address" : address.identifier ?: @"", @"name" : address.name, @"address" : address.address, @"latitude" : address.latitude, @"longitude" : address.longitude};
            CCLocalEvent *addressUpdateEvent = [CCLocalEvent insertInManagedObjectContext:managedObjectContext];
            addressUpdateEvent.eventValue = CCLocalEventAddressUpdated;
            addressUpdateEvent.date = [NSDate date];
            addressUpdateEvent.localAddressIdentifier = address.localIdentifier;
            addressUpdateEvent.parameters = parameters;
        }
        @catch(NSException *e) {
            CCLog(@"%@", e);
        }
    }
    [[CCLinotteCoreDataStack sharedInstance] saveContext];
}

- (void)addressesDidUpdateUserData:(NSArray *)addresses send:(BOOL)send
{
    if (send == NO)
        return;

    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    
    for (CCAddress *address in addresses) {
        @try {
            NSDictionary *parameters = @{@"address" : address.identifier ?: @"", @"note" : address.note, @"notification" : @(address.notifyValue)};
            CCLocalEvent *addressUpdateEvent = [CCLocalEvent insertInManagedObjectContext:managedObjectContext];
            addressUpdateEvent.eventValue = CCLocalEventAddressUserDataUpdated;
            addressUpdateEvent.date = [NSDate date];
            addressUpdateEvent.localAddressIdentifier = address.localIdentifier;
            addressUpdateEvent.parameters = parameters;
        }
        @catch(NSException *e) {
            CCLog(@"%@", e);
        }
    }
    
    [[CCLinotteCoreDataStack sharedInstance] saveContext];
}

- (void)addresses:(NSArray *)addresses didMoveToList:(CCList *)list send:(BOOL)send
{
    if (send == NO)
        return;

    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    
    for (CCAddress *address in addresses) {
        if (address.identifier == nil && [address.lists count] == 1) {
            @try {
                NSDictionary *parameters = @{@"name" : address.name, @"address" : address.address, @"latitude" : address.latitude, @"longitude" : address.longitude, @"provider" : address.provider, @"provider_id" : address.providerId};
                CCLocalEvent *addressCreatedEvent = [CCLocalEvent insertInManagedObjectContext:managedObjectContext];
                addressCreatedEvent.eventValue = CCLocalEventAddressCreated;
                addressCreatedEvent.date = [NSDate date];
                addressCreatedEvent.localAddressIdentifier = address.localIdentifier;
                addressCreatedEvent.parameters = parameters;
                
                NSError *error = nil;
                for (CCAddressMeta *addressMeta in address.metas) {
                    NSData *contentData = [NSJSONSerialization dataWithJSONObject:addressMeta.content options:0 error:&error];
                    NSString *contentString = [[NSString alloc] initWithData:contentData encoding:NSUTF8StringEncoding];
                    
                    if (error != nil) {
                        CCLog(@"%@", error);
                        continue;
                    }
                    
                    NSDictionary *parameters = @{@"uid" : addressMeta.uid, @"action" : addressMeta.action, @"content" : contentString};
                    CCLocalEvent *addressUpdateEvent = [CCLocalEvent insertInManagedObjectContext:managedObjectContext];
                    addressUpdateEvent.eventValue = CCLocalEventAddressMetaAdded;
                    addressUpdateEvent.date = [NSDate date];
                    addressUpdateEvent.localAddressIdentifier = address.localIdentifier;
                    addressUpdateEvent.parameters = parameters;
                }
            }
            @catch(NSException *e) {
                CCLog(@"%@", e);
            }
        }
        
        @try {
            NSDictionary *parameters = @{@"list" : list.identifier ?: @"", @"address" : address.identifier ?: @""};
            CCLocalEvent *addressMovedToListEvent = [CCLocalEvent insertInManagedObjectContext:managedObjectContext];
            addressMovedToListEvent.eventValue = CCLocalEventAddressMovedToList;
            addressMovedToListEvent.date = [NSDate date];
            addressMovedToListEvent.localAddressIdentifier = address.localIdentifier;
            addressMovedToListEvent.localListIdentifier = list.localIdentifier;
            addressMovedToListEvent.parameters = parameters;
        }
        @catch(NSException *e) {
            CCLog(@"%@", e);
        }
    }
    [[CCLinotteCoreDataStack sharedInstance] saveContext];
}

- (void)addresses:(NSArray *)addresses didMoveFromList:(CCList *)list send:(BOOL)send
{
    if (send == NO)
        return;
    
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;

    for (CCAddress *address in addresses) {
        @try {
            NSDictionary *parameters = @{@"list" : list.identifier ?: @"", @"address" : address.identifier ?: @""};
            CCLocalEvent *addressMovedFromListEvent = [CCLocalEvent insertInManagedObjectContext:managedObjectContext];
            addressMovedFromListEvent.eventValue = CCLocalEventAddressMovedFromList;
            addressMovedFromListEvent.date = [NSDate date];
            addressMovedFromListEvent.localListIdentifier = list.localIdentifier;
            addressMovedFromListEvent.localAddressIdentifier = address.localIdentifier;
            addressMovedFromListEvent.parameters = parameters;
        }
        @catch(NSException *e) {
            CCLog(@"%@", e);
        }
    }
    [[CCLinotteCoreDataStack sharedInstance] saveContext];
}

@end
