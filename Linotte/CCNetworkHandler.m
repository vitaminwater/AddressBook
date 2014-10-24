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

#import "CCModelChangeMonitor.h"

#import "CCLinotteAPI.h"

#import "CCNetworkEvent.h"
#import "CCAddress.h"
#import "CCList.h"


#define kCCEventChainLength 10

#define kCCNetworkHandlerAddToListEventCacheKey @"kCCNetworkHandlerAddToListEventCacheKey"


@implementation CCNetworkHandler
{
    CCDictStackCache *_cache;
    
    NSTimer *_timer;
    Reachability *_reachability;
    
    BOOL _isSendingEvent;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _cache = [CCDictStackCache new];
        _isSendingEvent = NO;

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

- (void)dequeueEvents:(NSUInteger)eventsSent eventChainEndBlock:(void(^)(NSUInteger eventsSent))eventChainEndBlock
{
    if (eventsSent > kCCEventChainLength || _isSendingEvent || _reachability.isReachable == NO) {
        eventChainEndBlock(eventsSent);
        return;
    }
    
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCNetworkEvent entityName]];
    fetchRequest.fetchLimit = 1;
    
    NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    [fetchRequest setSortDescriptors:@[dateSortDescriptor]];
    
    NSArray *events = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    
    if ([events count])
        [self sendEvent:[events firstObject] eventsSent:eventsSent eventChainEndBlock:eventChainEndBlock];
}

- (void)sendEvent:(CCNetworkEvent *)event eventsSent:(NSUInteger)eventsSent eventChainEndBlock:(void(^)(NSUInteger eventsSent))eventChainEndBlock
{
    _isSendingEvent = YES;
    
    void (^completionBlock)(BOOL success) = ^(BOOL success) {
        _isSendingEvent = NO;
        if (success) {
            NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
            [managedObjectContext deleteObject:event];
            [[CCCoreDataStack sharedInstance] saveContext];
            [self dequeueEvents:eventsSent + 1 eventChainEndBlock:eventChainEndBlock];
        }
    };
    
    switch (event.eventValue) {
        case CCNetworkEventAddressAdded:
        {
            [[CCLinotteAPI sharedInstance] createAddress:event.address completionBlock:completionBlock];
        }
            break;
        case CCNetworkEventListAdded:
        {
            [[CCLinotteAPI sharedInstance] createList:event.list completionBlock:completionBlock];
        }
            break;
        case CCNetworkEventListRemoved:
        {
            [[CCLinotteAPI sharedInstance] removeList:event.identifier completionBlock:completionBlock];
        }
            break;
        case CCNetworkEventAddressRemoved:
        {
            [[CCLinotteAPI sharedInstance] removeAddress:event.identifier completionBlock:completionBlock];
        }
            break;
        case CCNetworkEventAddressMovedToList:
        {
            [[CCLinotteAPI sharedInstance] addAddress:event.address toList:event.list completionBlock:completionBlock];
        }
            break;
        case CCNetworkEventAddressMovedFromList:
        {
            [[CCLinotteAPI sharedInstance] removeAddress:event.address fromList:event.list completionBlock:completionBlock];
        }
            break;
        case CCNetworkEventAddressUpdated:
        {
            [[CCLinotteAPI sharedInstance] updateAddress:event.address completionBlock:completionBlock];
        }
            break;
        case CCNetworkEventListUpdated:
        {
            [[CCLinotteAPI sharedInstance] updateList:event.list completionBlock:completionBlock];
        }
            break;
        case CCNetworkEventAddressUserDataUpdated:
        {
            [[CCLinotteAPI sharedInstance] updateAddressUserData:event.address completionBlock:completionBlock];
        }
            break;
        default:
            break;
    }
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
    abort();
}

#pragma mark - NSTimer management

- (void)startTimer
{
    if (_timer == nil) {
        _timer = [NSTimer timerWithTimeInterval:20.0 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
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
    if ([self canSend])
        [self dequeueEvents:0 eventChainEndBlock:^(NSUInteger eventsSent) {}];
}

#pragma mark CCModelChangeMonitorDelegate methods

- (void)listDidAdd:(CCList *)list
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    CCNetworkEvent *listAddEvent = [CCNetworkEvent insertInManagedObjectContext:managedObjectContext];
    listAddEvent.eventValue = CCNetworkEventListAdded;
    listAddEvent.date = [NSDate date];
    listAddEvent.list = list;
    [[CCCoreDataStack sharedInstance] saveContext];
}

- (void)listDidRemove:(NSString *)identifier
{
    if (identifier == nil)
        return;
    
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    CCNetworkEvent *listRemoveEvent = [CCNetworkEvent insertInManagedObjectContext:managedObjectContext];
    listRemoveEvent.eventValue = CCNetworkEventListRemoved;
    listRemoveEvent.date = [NSDate date];
    listRemoveEvent.identifier = identifier;
    [[CCCoreDataStack sharedInstance] saveContext];
}

- (void)listDidUpdate:(CCList *)list
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"list = %@ AND event = %@", list, @(CCNetworkEventListUpdated)];
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCNetworkEvent entityName]];
        [fetchRequest setPredicate:predicate];
        
        if ([managedObjectContext countForFetchRequest:fetchRequest error:NULL] != 0)
            return;
    }
    
    CCNetworkEvent *listUpdateEvent = [CCNetworkEvent insertInManagedObjectContext:managedObjectContext];
    listUpdateEvent.eventValue = CCNetworkEventListUpdated;
    listUpdateEvent.date = [NSDate date];
    listUpdateEvent.list = list;
    [[CCCoreDataStack sharedInstance] saveContext];
}

- (void)addressDidAdd:(CCAddress *)address
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    CCNetworkEvent *addressAddEvent = [CCNetworkEvent insertInManagedObjectContext:managedObjectContext];
    addressAddEvent.eventValue = CCNetworkEventAddressAdded;
    addressAddEvent.date = [NSDate date];
    addressAddEvent.address = address;
    [[CCCoreDataStack sharedInstance] saveContext];
}

- (void)addressDidRemove:(NSString *)identifier
{
    if (identifier == nil)
        return;
    
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    CCNetworkEvent *addressRemoveEvent = [CCNetworkEvent insertInManagedObjectContext:managedObjectContext];
    addressRemoveEvent.eventValue = CCNetworkEventAddressRemoved;
    addressRemoveEvent.date = [NSDate date];
    addressRemoveEvent.identifier = identifier;
    [[CCCoreDataStack sharedInstance] saveContext];
}

- (void)addressDidUpdate:(CCAddress *)address
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"address = %@ AND event = %@", address, @(CCNetworkEventAddressUpdated)];
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCNetworkEvent entityName]];
        [fetchRequest setPredicate:predicate];
        
        if ([managedObjectContext countForFetchRequest:fetchRequest error:NULL] != 0)
            return;
    }
    
    CCNetworkEvent *addressUpdateEvent = [CCNetworkEvent insertInManagedObjectContext:managedObjectContext];
    addressUpdateEvent.eventValue = CCNetworkEventAddressUpdated;
    addressUpdateEvent.date = [NSDate date];
    addressUpdateEvent.address = address;
    [[CCCoreDataStack sharedInstance] saveContext];
}

- (void)addressDidUpdateUserData:(CCAddress *)address
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"address = %@ AND event = %@", address, @(CCNetworkEventAddressUserDataUpdated)];
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCNetworkEvent entityName]];
        [fetchRequest setPredicate:predicate];
        
        if ([managedObjectContext countForFetchRequest:fetchRequest error:NULL] != 0)
            return;
    }
    
    CCNetworkEvent *addressUpdateEvent = [CCNetworkEvent insertInManagedObjectContext:managedObjectContext];
    addressUpdateEvent.eventValue = CCNetworkEventAddressUserDataUpdated;
    addressUpdateEvent.date = [NSDate date];
    addressUpdateEvent.address = address;
    [[CCCoreDataStack sharedInstance] saveContext];
}

- (void)address:(CCAddress *)address didMoveToList:(CCList *)list
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    // remove useless events
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"list = %@ AND address = %@ AND event = %@", address, list, @(CCNetworkEventAddressMovedFromList)];
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCNetworkEvent entityName]];
        [fetchRequest setPredicate:predicate];
        
        NSArray *removeFromListEvents = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
        if ([removeFromListEvents count]) {
            for (CCNetworkEvent *addToListEvent in removeFromListEvents) {
                [managedObjectContext deleteObject:addToListEvent];
            }
            return;
        }
    }
    CCNetworkEvent *addressMovedToListEvent = [CCNetworkEvent insertInManagedObjectContext:managedObjectContext];
    addressMovedToListEvent.eventValue = CCNetworkEventAddressMovedToList;
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
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"list = %@ AND address = %@ AND event = %@", address, list, @(CCNetworkEventAddressMovedToList)];
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
    addressMovedFromListEvent.eventValue = CCNetworkEventAddressMovedFromList;
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
