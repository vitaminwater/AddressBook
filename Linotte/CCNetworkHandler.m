//
//  CCNetworkHandler.m
//  Linotte
//
//  Created by stant on 15/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCNetworkHandler.h"

#import <Mixpanel/Mixpanel.h>

#import <Reachability/Reachability.h>

#import "CCCoreDataStack.h"

#import "CCModelChangeMonitor.h"

#import "CCLinotteAPI.h"

#import "CCNetworkEvent.h"
#import "CCAddress.h"
#import "CCList.h"


@implementation CCNetworkHandler
{
    NSTimer *_timer;
    Reachability *_reachability;
    
    BOOL _isSendingEvent;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isSendingEvent = NO;

        if ([CCLinotteAPI sharedInstance].loggedState == kCCLoggedIn) {
            [[Mixpanel sharedInstance] track:@"Application started" properties:@{@"date": [NSDate date]}];
        }
        
        __weak typeof(self) weakSelf = self;
        _reachability = [Reachability reachabilityWithHostname:@"getlinotte.com"];
        _reachability.reachableBlock = ^(Reachability *reachability) {
            [weakSelf reachable];
        };
        _reachability.unreachableBlock = ^(Reachability *reachability) {
            [weakSelf unreachable];
        };
        [_reachability startNotifier];
        
        [[CCModelChangeMonitor sharedInstance] addDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [[CCModelChangeMonitor sharedInstance] removeDelegate:self];
}

- (void)reachable
{
    // Cleaning purpose: remove when db clean
    if ([CCLinotteAPI sharedInstance].loggedState == kCCFirstStart)
        [self resetAllAdresses];
    
    [[CCLinotteAPI sharedInstance] APIIinitialization:^(BOOL newUserCreated) {
        if ([CCLinotteAPI sharedInstance].loggedState != kCCLoggedIn)
            return;
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel identify:[CCLinotteAPI sharedInstance].identifier];
        if (newUserCreated) {
            [[mixpanel people] set:@"$created" to:[NSDate date]];
        }
        [self startTimer];
    }];
}

- (void)unreachable
{
    [self stopTimer];
}

- (void)dequeueEvent
{
    if (_isSendingEvent)
        return;
    
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCNetworkEvent entityName]];
    fetchRequest.fetchLimit = 1;
    
    NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    [fetchRequest setSortDescriptors:@[dateSortDescriptor]];
    
    NSArray *events = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    
    if ([events count])
        [self sendEvent:[events firstObject]];
}

- (void)sendEvent:(CCNetworkEvent *)event
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    _isSendingEvent = YES;
    switch (event.eventValue) {
        case CCNetworkEventEventAddressAdded:
        {
            [[CCLinotteAPI sharedInstance] createAddress:event.address completionBlock:^(BOOL success) {
                if (success) {
                    _isSendingEvent = NO;
                    [managedObjectContext deleteObject:event];
                    [self dequeueEvent];
                }
            }];
        }
            break;
        case CCNetworkEventEventListAdded:
        {
            [[CCLinotteAPI sharedInstance] createList:event.list completionBlock:^(BOOL success) {
                if (success) {
                    _isSendingEvent = NO;
                    [managedObjectContext deleteObject:event];
                    [self dequeueEvent];
                }
            }];
        }
            break;
        case CCNetworkEventEventListRemoved:
        {
            [[CCLinotteAPI sharedInstance] removeList:event.identifier completionBlock:^(BOOL success) {
                if (success) {
                    _isSendingEvent = NO;
                    [managedObjectContext deleteObject:event];
                    [self dequeueEvent];
                }
            }];
        }
            break;
        case CCNetworkEventEventAddressMovedToList:
        {
            [[CCLinotteAPI sharedInstance] addAddress:event.address toList:event.list completionBlock:^(BOOL success) {
                if (success) {
                    _isSendingEvent = NO;
                    [managedObjectContext deleteObject:event];
                    [self dequeueEvent];
                }
            }];
        }
            break;
        case CCNetworkEventEventAddressMovedFromList:
        {
            [[CCLinotteAPI sharedInstance] removeAddress:event.address fromList:event.list completionBlock:^(BOOL success) {
                if (success) {
                    _isSendingEvent = NO;
                    [managedObjectContext deleteObject:event];
                    [self dequeueEvent];
                }
            }];
        }
            break;
        case CCNetworkEventEventAddressUpdated:
        {
            [[CCLinotteAPI sharedInstance] updateAddress:event.address completionBlock:^(BOOL success) {
                if (success) {
                    _isSendingEvent = NO;
                    [managedObjectContext deleteObject:event];
                    [self dequeueEvent];
                }
            }];
        }
            break;
        case CCNetworkEventEventListUpdated:
        {
            [[CCLinotteAPI sharedInstance] updateList:event.list completionBlock:^(BOOL success) {
                if (success) {
                    _isSendingEvent = NO;
                    [managedObjectContext deleteObject:event];
                    [self dequeueEvent];
                }
            }];
        }
            break;
        default:
            break;
    }
}

#pragma mark - getter methods

- (BOOL)canSend
{
    return _reachability.isReachable && [CCLinotteAPI sharedInstance].loggedState == kCCLoggedIn;
}

- (BOOL)connectionAvailable
{
    return _reachability.isReachable;
}

#pragma mark - cleaning methods

- (void)resetAllAdresses
{
    NSError *error;
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sent=%@", @YES];
    [fetchRequest setPredicate:predicate];
    
    NSArray *addresses = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error != NULL) {
        NSLog(@"%@", error);
    }
    
    if ([addresses count] == 0)
        return;
    
    for (CCAddress *address in addresses) {
        address.sent = @NO;
        [self addressDidAdd:address];
    }
    
    [[CCCoreDataStack sharedInstance] saveContext];
}

#pragma mark - NSTimer management

- (void)startTimer
{
    if (_timer == nil) {
        _timer = [NSTimer timerWithTimeInterval:20.0 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        
        [_timer fire];
    }
}

- (void)stopTimer
{
    [_timer invalidate];
    _timer = nil;
}

#pragma mark - timer target

- (void)timerTick:(NSTimer *)timer
{
    if ([self canSend])
        [self dequeueEvent];
}

#pragma mark CCModelChangeMonitorDelegate methods

- (void)listDidAdd:(CCList *)list
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    CCNetworkEvent *listAddEvent = [CCNetworkEvent insertInManagedObjectContext:managedObjectContext];
    listAddEvent.eventValue = CCNetworkEventEventListAdded;
    listAddEvent.date = [NSDate date];
    listAddEvent.list = list;
    [[CCCoreDataStack sharedInstance] saveContext];
}

- (void)listDidRemove:(CCList *)list
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    // remove useless events
    // not sure what to do actually... maybe keep the address flagged as "toDelete" and delete when all events are processed ? as of now delete rule is "cascade"
    
    CCNetworkEvent *listRemoveEvent = [CCNetworkEvent insertInManagedObjectContext:managedObjectContext];
    listRemoveEvent.eventValue = CCNetworkEventEventListRemoved;
    listRemoveEvent.date = [NSDate date];
    listRemoveEvent.identifier = list.identifier;
    [[CCCoreDataStack sharedInstance] saveContext];
}

- (void)listDidUpdate:(CCList *)list
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    // remove useless events
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"list = %@ AND event = %@", list, @(CCNetworkEventEventListUpdated)];
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCNetworkEvent entityName]];
        [fetchRequest setPredicate:predicate];
        
        NSArray *listUpdateEvents = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
        for (CCNetworkEvent *listUpdateEvent in listUpdateEvents) {
            [managedObjectContext deleteObject:listUpdateEvent];
        }
    }
    
    CCNetworkEvent *listUpdateEvent = [CCNetworkEvent insertInManagedObjectContext:managedObjectContext];
    listUpdateEvent.eventValue = CCNetworkEventEventListUpdated;
    listUpdateEvent.date = [NSDate date];
    listUpdateEvent.list = list;
    [[CCCoreDataStack sharedInstance] saveContext];
}

- (void)addressDidAdd:(CCAddress *)address
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    CCNetworkEvent *addressAddEvent = [CCNetworkEvent insertInManagedObjectContext:managedObjectContext];
    addressAddEvent.eventValue = CCNetworkEventEventAddressAdded;
    addressAddEvent.date = [NSDate date];
    addressAddEvent.address = address;
    [[CCCoreDataStack sharedInstance] saveContext];
}

- (void)addressDidRemove:(CCAddress *)address
{
    // NSManagedObjectContext *managedObjectContext = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    
    // remove useless events
    // not sure what to do actually... maybe keep the address flagged as "toDelete" and delete when all events are processed ? as of now delete rule is "cascade"
    
    // TODO : call addressRemovedFromList with default list
    /* CCNetworkEvent *addressRemoveEvent = [CCNetworkEvent insertInManagedObjectContext:managedObjectContext];
    addressRemoveEvent.eventValue = CCNetworkEventEventAddressRemoved;
    addressRemoveEvent.date = [NSDate date];
    addressRemoveEvent.identifier = address.identifier;
    [managedObjectContext saveToPersistentStore:NULL]; */
}

- (void)addressDidUpdate:(CCAddress *)address
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    // remove useless events
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"address = %@ AND event = %@", address, @(CCNetworkEventEventAddressUpdated)];
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCNetworkEvent entityName]];
        [fetchRequest setPredicate:predicate];
        
        NSArray *addressDidUpdateEvents = [managedObjectContext executeFetchRequest:fetchRequest error:NULL]; // TODO check error
        if ([addressDidUpdateEvents count]) {
            for (CCNetworkEvent *addressDidUpdateEvent in addressDidUpdateEvents) {
                [managedObjectContext deleteObject:addressDidUpdateEvent];
            }
        }
    }
    
    CCNetworkEvent *addressUpdateEvent = [CCNetworkEvent insertInManagedObjectContext:managedObjectContext];
    addressUpdateEvent.eventValue = CCNetworkEventEventAddressUpdated;
    addressUpdateEvent.date = [NSDate date];
    addressUpdateEvent.address = address;
    [[CCCoreDataStack sharedInstance] saveContext];
}

- (void)address:(CCAddress *)address didMoveToList:(CCList *)list
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    CCNetworkEvent *addressMovedToListEvent = [CCNetworkEvent insertInManagedObjectContext:managedObjectContext];
    addressMovedToListEvent.eventValue = CCNetworkEventEventAddressMovedToList;
    addressMovedToListEvent.address = address;
    addressMovedToListEvent.date = [NSDate date];
    addressMovedToListEvent.list = list;
    [[CCCoreDataStack sharedInstance] saveContext];
}

- (void)address:(CCAddress *)address didMoveFromList:(CCList *)list
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;

    // remove useless events
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"list = %@ AND address = %@ AND event = %@", address, list, @(CCNetworkEventEventAddressMovedToList)];
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCNetworkEvent entityName]];
        [fetchRequest setPredicate:predicate];
        
        NSArray *addToListEvents = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
        if ([addToListEvents count]) {
            for (CCNetworkEvent *addToListEvent in addToListEvents) {
                [managedObjectContext deleteObject:addToListEvent];
            }
            return;
        }
    }
    
    CCNetworkEvent *addressMovedFromListEvent = [CCNetworkEvent insertInManagedObjectContext:managedObjectContext];
    addressMovedFromListEvent.eventValue = CCNetworkEventEventAddressMovedFromList;
    addressMovedFromListEvent.date = [NSDate date];
    addressMovedFromListEvent.address = address;
    addressMovedFromListEvent.list = list;
    [[CCCoreDataStack sharedInstance] saveContext];
}

#pragma mark - Singleton method

+ (instancetype)sharedInstance
{
    static id instance = nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        instance = [self new];
    });
    
    return instance;
}

@end
