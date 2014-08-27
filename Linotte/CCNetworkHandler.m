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

#import "CCRestKit.h"
#import "CCLocalAPI.h"

@interface CCNetworkHandler()

@property(nonatomic, strong)NSTimer *timer;
@property(nonatomic, strong)Reachability *reachability;

@property(nonatomic, strong)NSMutableArray *addresses;
@property(nonatomic, strong)NSMutableArray *loadingAddresses;

@end

@implementation CCNetworkHandler

- (id)init
{
    self = [super init];
    if (self) {
        _addresses = [@[] mutableCopy];
        _loadingAddresses = [@[] mutableCopy];
        
        if ([CCLocalAPI sharedInstance].loggedState == kCCLoggedIn) {
            [[Mixpanel sharedInstance] track:@"Application started" properties:@{@"date": [NSDate date]}];
        }
        
        __weak id weakSelf = self;
        _reachability = [Reachability reachabilityWithHostname:@"getlinotte.com"];
        _reachability.reachableBlock = ^(Reachability *reachability) {
            [weakSelf reachable];
        };
        _reachability.unreachableBlock = ^(Reachability *reachability) {
            [weakSelf unreachable];
        };
        [_reachability startNotifier];
        
        [self loadInitialAddresses];
        
        NSLog(@"%d", _reachability.isReachable);
    }
    return self;
}

- (void)loadInitialAddresses {
    NSError *error = NULL;
    NSManagedObjectContext *managedObjectContext = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sent=%@", @NO];
    [fetchRequest setPredicate:predicate];
    
    NSArray *addresses = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error != NULL) {
        NSLog(@"%@", error);
    }
    [_addresses addObjectsFromArray:addresses];
    
}

- (void)reachable {
    [[CCLocalAPI sharedInstance] APIIinitialization:^(BOOL newUserCreated) {
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel identify:[CCLocalAPI sharedInstance].identifier];
        if (newUserCreated) {
            [[mixpanel people] set:@"$created" to:[NSDate date]];
        }
        [self startTimer];
    }];
}

- (void)unreachable {
    [self stopTimer];
}

- (void)sendAddress:(CCAddress *)address
{
    if ([self canSend]) {
        [[CCLocalAPI sharedInstance] sendAddress:address completionBlock:^(BOOL success) {
            if (success == NO) {
                [_addresses addObject:address];
            } else {
                [self validateAddressSent:address];
            }
        }];
    } else {
        [_addresses addObject:address];
    }
}

- (void)purgeAddresses {
    if ([_addresses count] == 0 || [_loadingAddresses count] >= 5)
        return;
    
    for (CCAddress *address in _addresses) {
        if ([_loadingAddresses containsObject:address])
            continue;
        [_loadingAddresses addObject:address];
        [[CCLocalAPI sharedInstance] sendAddress:address completionBlock:^(BOOL success) {
            if (success == YES) {
                [_addresses removeObject:address];
                [self validateAddressSent:address];
            }
            [_loadingAddresses removeObject:address];
        }];
        if ([_loadingAddresses count] >= 5)
            return;
    }
}

- (void)validateAddressSent:(CCAddress *)address
{
    address.sent = @YES;
    [[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext saveToPersistentStore:NULL];
}

#pragma mark - getter methods

- (BOOL)canSend
{
    return _reachability.isReachable && [CCLocalAPI sharedInstance].loggedState == kCCLoggedIn;
}

- (BOOL)connectionAvailable
{
    return _reachability.isReachable;
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
        [self purgeAddresses];
}

#pragma mark - Singleton method

+ (instancetype)sharedInstance
{
    static id instance = nil;
    
    if (instance == nil)
        instance = [self new];
    
    return instance;
}

@end
