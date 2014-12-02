//
//  CCUserSynchronizationActionConsumeEvents.m
//  Linotte
//
//  Created by stant on 20/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCUserSynchronizationActionConsumeEvents.h"

#import "CCLinotteAPI.h"
#import "CCCoreDataStack.h"

#import "CCServerEventListAddedConsumer.h"
#import "CCServerEventListRemovedConsumer.h"

#import "CCUserDefaults.h"
#import "CCList.h"

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
    
    _currentConnection = [[CCLinotteAPI sharedInstance] fetchUserEventsWithLastDate:lastUserEventDate completionBlock:^(BOOL success, NSArray *eventsDicts) {
        
        _currentConnection = nil;
        if (success == NO) {
            completionBlock(NO, YES);
            return;
        }
        
        if ([eventsDicts count] == 0) {
            completionBlock(NO, NO);
            return;
        }
        
        CCLog(@"%lu user events received", [eventsDicts count]);
        NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
        NSDate *lastEventDate = nil;
        for (NSDictionary *eventDict in eventsDicts) {
            CCServerEvent *serverEvent = [CCServerEvent insertInManagedObjectContext:managedObjectContext fromLinotteAPIDict:eventDict];
            lastEventDate = serverEvent.date;
        }
        CCUD.lastUserEventDate = lastEventDate;

        [[CCCoreDataStack sharedInstance] saveContext];
        completionBlock(YES, NO);
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
    
    [super triggerWithList:list coordinates:coordinates completionBlock:completionBlock];
}

@end
