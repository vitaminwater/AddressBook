//
//  CCUserSynchronizationActionConsumeEvents.m
//  Linotte
//
//  Created by stant on 20/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCUserSynchronizationActionConsumeEvents.h"

#import "CCLinotteEngineCoordinator.h"
#import "CCLinotteAPI.h"
#import "CCLinotteCoreDataStack.h"

#import "CCServerEventListAddedConsumer.h"
#import "CCServerEventListRemovedConsumer.h"

#import "CCCurrentUserData.h"
#import "CCList.h"

#define kCCDateIntervalDifference -(12 * 60 * 60)

@implementation CCUserSynchronizationActionConsumeEvents
{
    CCList *_currentList;
    NSURLSessionTask *_currentConnection;
    
    NSArray *_consumers;
    NSArray *_events;
}

- (instancetype)init
{
    self = [super initWithProvider:self];
    if (self) {
        _consumers = @[[CCServerEventListAddedConsumer new], [CCServerEventListRemovedConsumer new]];
        _events = [_consumers valueForKeyPath:@"@unionOfObjects.event"];
    }
    return self;
}

- (NSArray *)consumers
{
    return _consumers;
}

- (CCList *)findNextListToProcess
{
    return nil;
}

- (NSArray *)eventsList
{
    return _events;
}

- (void)fetchServerEventsWithList:(CCList *)list completionBlock:(void(^)(BOOL goOnSyncing, BOOL error))completionBlock
{
    NSDate *lastUserEventDate = CCUD.lastUserEventDate;
    
    _currentConnection = [CCLEC.linotteAPI fetchUserEventsWithLastDate:lastUserEventDate success:^(NSArray *eventsDicts) {
        _currentConnection = nil;
        
        CCUD.lastUserEventUpdate = [NSDate date];
        if ([eventsDicts count] == 0) {
            completionBlock(NO, NO);
            return;
        }
        
        CCLog(@"%lu user events received", [eventsDicts count]);
        NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
        NSDate *lastEventDate = nil;
        for (NSDictionary *eventDict in eventsDicts) {
            CCServerEvent *serverEvent = [CCServerEvent insertInManagedObjectContext:managedObjectContext fromLinotteAPIDict:eventDict];
            lastEventDate = serverEvent.date;
        }
        CCUD.lastUserEventDate = lastEventDate;
        
        [[CCLinotteCoreDataStack sharedInstance] saveContext];
        completionBlock(YES, NO);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        _currentConnection = nil;
        
        completionBlock(NO, YES);
    }];
}

- (BOOL)requiresList
{
    return NO;
}

#pragma mark - overriden methods

- (void)triggerWithList:(CCList *)list coordinates:(CLLocationCoordinate2D)coordinates completionBlock:(void (^)(BOOL, BOOL))completionBlock
{
    if (list != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(NO, NO);
        });
        return;
    }
    
    NSDate *lastUserEventDate = CCUD.lastUserEventDate;

    if (lastUserEventDate == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(NO, NO);
        });
        return;
    }
    
    NSDate *minDate = [[NSDate date] dateByAddingTimeInterval:kCCDateIntervalDifference];
    NSDate *lastUserEventUpdate = CCUD.lastUserEventUpdate;
    
    if ([lastUserEventUpdate compare:minDate] != NSOrderedAscending) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(NO, NO);
        });
        return;
    }
    
    [super triggerWithList:list coordinates:coordinates completionBlock:completionBlock];
}

@end
