//
//  CCNetworkHandler.m
//  Linotte
//
//  Created by stant on 15/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCNetworkHandler.h"

#import "CCLocalAPI.h"

#import <Reachability/Reachability.h>

#import "CCRestKit.h"
#import "CCLocalAPI.h"

typedef enum : NSUInteger {
    kCCNotLogged,
    kCCLoggedIn,
    kCCFailed,
} CCLoggedState;

@interface CCNetworkHandler()

@property(nonatomic, assign)CCLoggedState loggedState;

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
        
        _loggedState = [[CCLocalAPI sharedInstance] isLoggedIn] ? kCCLoggedIn : kCCNotLogged;
        
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
    BOOL isLoggedIn = [[CCLocalAPI sharedInstance] isLoggedIn];
    if (_loggedState == kCCNotLogged && isLoggedIn == NO) {
        [self createNewUser];
    } else if (_loggedState == kCCNotLogged) {
        [self refreshToken];
    } else if (_loggedState == kCCLoggedIn) {
        [self startTimer];
    }
}

- (void)unreachable {
    [self stopTimer];
}

- (void)createNewUser
{
    [[CCLocalAPI sharedInstance] createAndAuthenticateAnonymousUserWithCompletionBlock:^(bool success) {
        if (success) {
            _loggedState = kCCLoggedIn;
            [self startTimer];
        } else {
            _loggedState = kCCFailed;
        }
    }];
}

- (void)refreshToken
{
    [[CCLocalAPI sharedInstance] refreshTokenWithCompletionBlock:^(bool success) {
        if (success) {
            _loggedState = kCCLoggedIn;
            [self startTimer];
        } else {
            _loggedState = kCCFailed;
        }
    }];
}

- (void)sendAddress:(CCAddress *)address
{
    if ([self canSend]) {
        [[CCLocalAPI sharedInstance] sendAddress:address completionBlock:^(bool success) {
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
    if ([_addresses count] == 0)
        return;
    
    for (CCAddress *address in _addresses) {
        if ([_loadingAddresses containsObject:address])
            continue;
        [_loadingAddresses addObject:address];
        [[CCLocalAPI sharedInstance] sendAddress:address completionBlock:^(bool success) {
            if (success == YES) {
                [_addresses removeObject:address];
                [self validateAddressSent:address];
            }
            [_loadingAddresses removeObject:address];
        }];
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
    return _reachability.isReachable && _loggedState == kCCLoggedIn;
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
