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
#import "CCDictStackCache.h"

#import "CCSynchronizationHandler.h"

#import "CCModelChangeMonitor.h"

#import "CCLinotteAPI.h"

#import "CCLocalEvent.h"
#import "CCAddress.h"
#import "CCList.h"


#define kCCEventChainLength 10

#define kCCLocalEventListRemoveLocalIdentifierCacheKey @"kCCLocalEventListRemoveLocalIdentifierCacheKey"


@implementation CCNetworkHandler
{
    CCDictStackCache *_cache;
    
    NSTimer *_timer;
    Reachability *_reachability;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _cache = [CCDictStackCache new];

        if ([CCLinotteAPI sharedInstance].loggedState == kCCFirstStart)
            [self resetAllAdresses];
        
        __weak typeof(self) weakSelf = self;
        _reachability = [Reachability reachabilityWithHostname:@"google.com"];
        _reachability.reachableBlock = ^(Reachability *reachability) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf reachable];
            });
        };
        _reachability.unreachableBlock = ^(Reachability *reachability) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf unreachable];
            });
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
    if ([CCLinotteAPI sharedInstance].loggedState != kCCLoggedIn)
        [self initializeLinotteAPI];
    else
        [self startTimer];
}

- (void)unreachable
{
    [self stopTimer];
}

- (void)initializeLinotteAPI
{
    [[CCLinotteAPI sharedInstance] APIIinitialization:^(CCLoggedState fromState) {
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        if (mixpanel.distinctId == nil) {
            [mixpanel identify:[CCLinotteAPI sharedInstance].identifier];
            if (fromState == kCCFirstStart) {
                [[mixpanel people] set:@"$created" to:[NSDate date]];
            }
        }
    } completionBock:^(BOOL success) {
        if (success == NO) {
            if (_reachability.isReachable) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self initializeLinotteAPI];
                });
            }
        } else {
            [self startTimer];
        }
    }];
}



#pragma mark - getter methods

- (BOOL)canSend
{
    return [self connectionAvailable] && [CCLinotteAPI sharedInstance].loggedState == kCCLoggedIn;
}

- (BOOL)connectionAvailable
{
    return _reachability.isReachable;
}

#pragma mark - cleaning methods

// TODO redo migration !
- (void)resetAllAdresses
{
    /*NSError *error;
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
        [self addressDidAdd:address];
    }
    
    [[CCCoreDataStack sharedInstance] saveContext];*/
    //abort();
}

#pragma mark - NSTimer management

- (void)startTimer
{
    if (_timer == nil) {
        _timer = [NSTimer timerWithTimeInterval:10.0 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
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
    if ([CCSynchronizationHandler sharedInstance].syncing == YES || [self canSend] == NO)
        return;
    [[CCSynchronizationHandler sharedInstance] performSynchronizationsWithMaxDuration:0 list:nil completionBlock:^(BOOL didSync){}];
}

#pragma mark CCModelChangeMonitorDelegate methods

- (void)listDidAdd:(CCList *)list send:(BOOL)send
{
    if (send == NO)
        return;

    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    CCLocalEvent *listAddEvent = [CCLocalEvent insertInManagedObjectContext:managedObjectContext];
    listAddEvent.eventValue = CCLocalEventListCreated;
    listAddEvent.date = [NSDate date];
    listAddEvent.localListIdentifier = list.localIdentifier;
    listAddEvent.parameters = @{@"name" : list.name};
    [[CCCoreDataStack sharedInstance] saveContext];
}

- (void)listWillRemove:(CCList *)list send:(BOOL)send
{
    [_cache pushCacheEntry:kCCLocalEventListRemoveLocalIdentifierCacheKey value:list.localIdentifier];
}

- (void)listDidRemove:(NSString *)identifier send:(BOOL)send
{
    if (send == NO)
        return;
    
    NSString *localIdentifier = [_cache popCacheEntry:kCCLocalEventListRemoveLocalIdentifierCacheKey];
    
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    CCLocalEvent *listRemoveEvent = [CCLocalEvent insertInManagedObjectContext:managedObjectContext];
    listRemoveEvent.eventValue = CCLocalEventListRemoved;
    listRemoveEvent.date = [NSDate date];
    listRemoveEvent.localListIdentifier = localIdentifier;
    if (identifier != nil)
        listRemoveEvent.parameters = @{@"list": identifier};
    [[CCCoreDataStack sharedInstance] saveContext];
}

- (void)listDidUpdate:(CCList *)list send:(BOOL)send
{
    if (send == NO)
        return;

    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    CCLocalEvent *listUpdateEvent = [CCLocalEvent insertInManagedObjectContext:managedObjectContext];
    listUpdateEvent.eventValue = CCLocalEventListUpdated;
    listUpdateEvent.date = [NSDate date];
    listUpdateEvent.localListIdentifier = list.localIdentifier;
    listUpdateEvent.parameters = @{@"list" : list.identifier == nil ? @"" : list.identifier, @"name" : list.name};
    [[CCCoreDataStack sharedInstance] saveContext];
}

- (void)listDidUpdateUserData:(CCList *)list send:(BOOL)send
{
    if (send == NO)
        return;
    
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    CCLocalEvent *listUpdateEvent = [CCLocalEvent insertInManagedObjectContext:managedObjectContext];
    listUpdateEvent.eventValue = CCLocalEventListUserDataUpdated;
    listUpdateEvent.date = [NSDate date];
    listUpdateEvent.localListIdentifier = list.localIdentifier;
    listUpdateEvent.parameters = @{@"list" : list.identifier == nil ? @"" : list.identifier, @"notify" : list.notify};
    [[CCCoreDataStack sharedInstance] saveContext];
}

- (void)addressesDidUpdate:(NSArray *)addresses send:(BOOL)send
{
    if (send == NO)
        return;

    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    for (CCAddress *address in addresses) {
        CCLocalEvent *addressUpdateEvent = [CCLocalEvent insertInManagedObjectContext:managedObjectContext];
        addressUpdateEvent.eventValue = CCLocalEventAddressUpdated;
        addressUpdateEvent.date = [NSDate date];
        addressUpdateEvent.localAddressIdentifier = address.localIdentifier;
        addressUpdateEvent.parameters = @{@"address" : address.identifier == nil ? @"" : address.identifier, @"name" : address.name, @"address" : address.address, @"latitude" : address.latitude, @"longitude" : address.longitude};
    }
    [[CCCoreDataStack sharedInstance] saveContext];
}

- (void)addressesDidUpdateUserData:(NSArray *)addresses send:(BOOL)send
{
    if (send == NO)
        return;

    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    for (CCAddress *address in addresses) {
        CCLocalEvent *addressUpdateEvent = [CCLocalEvent insertInManagedObjectContext:managedObjectContext];
        addressUpdateEvent.eventValue = CCLocalEventAddressUserDataUpdated;
        addressUpdateEvent.date = [NSDate date];
        addressUpdateEvent.localAddressIdentifier = address.localIdentifier;
        addressUpdateEvent.parameters = @{@"address" : address.identifier == nil ? @"" : address.identifier, @"note" : address.note, @"notification" : @(address.notifyValue)};
    }
    
    [[CCCoreDataStack sharedInstance] saveContext];
}

- (void)addresses:(NSArray *)addresses didMoveToList:(CCList *)list send:(BOOL)send
{
    if (send == NO)
        return;

    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    for (CCAddress *address in addresses) {
        if (address.identifier == nil && [address.lists count] == 1) {
            CCLocalEvent *addressCreatedEvent = [CCLocalEvent insertInManagedObjectContext:managedObjectContext];
            addressCreatedEvent.eventValue = CCLocalEventAddressCreated;
            addressCreatedEvent.date = [NSDate date];
            addressCreatedEvent.localAddressIdentifier = address.localIdentifier;
            addressCreatedEvent.parameters = @{@"name" : address.name, @"address" : address.address, @"latitude" : address.latitude, @"longitude" : address.longitude, @"provider" : address.provider, @"provider_id" : address.providerId};
        }
        
        CCLocalEvent *addressMovedToListEvent = [CCLocalEvent insertInManagedObjectContext:managedObjectContext];
        addressMovedToListEvent.eventValue = CCLocalEventAddressMovedToList;
        addressMovedToListEvent.date = [NSDate date];
        addressMovedToListEvent.localAddressIdentifier = address.localIdentifier;
        addressMovedToListEvent.localListIdentifier = list.localIdentifier;
        addressMovedToListEvent.parameters = @{@"list" : list.identifier == nil ? @"" : list.identifier, @"address" : address.identifier == nil ? @"" : address.identifier};
    }
    [[CCCoreDataStack sharedInstance] saveContext];
}

- (void)addresses:(NSArray *)addresses didMoveFromList:(CCList *)list send:(BOOL)send
{
    if (send == NO)
        return;
    
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;

    for (CCAddress *address in addresses) {
        CCLocalEvent *addressMovedFromListEvent = [CCLocalEvent insertInManagedObjectContext:managedObjectContext];
        addressMovedFromListEvent.eventValue = CCLocalEventAddressMovedFromList;
        addressMovedFromListEvent.date = [NSDate date];
        addressMovedFromListEvent.localListIdentifier = list.localIdentifier;
        addressMovedFromListEvent.localAddressIdentifier = address.localIdentifier;
        addressMovedFromListEvent.parameters = @{@"list" : list.identifier == nil ? @"" : list.identifier, @"address" : address.identifier == nil ? @"" : address.identifier};
    }
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
