//
//  CCListSynchronizationActionConsumeEvents.m
//  Linotte
//
//  Created by stant on 17/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListSynchronizationActionConsumeEvents.h"

#import "CCCoreDataStack.h"

#import "CCLinotteAPI.h"

#import "CCServerEventListUpdatedConsumer.h"
#import "CCServerEventListMetaAddedConsumer.h"
#import "CCServerEventListMetaUpdatedConsumer.h"
#import "CCServerEventListMetaDeletedConsumer.h"

#import "CCList.h"
#import "CCListZone.h"
#import "CCServerEvent.h"

@implementation CCListSynchronizationActionConsumeEvents
{
    CCList *_currentList;
    NSURLSessionTask *_currentConnection;
}

- (instancetype)init
{
    self = [super initWithProvider:self];
    if (self) {
    }
    return self;
}

- (NSArray *)consumers
{
    return @[
             [CCServerEventListUpdatedConsumer new],
             [CCServerEventListMetaAddedConsumer new],
             [CCServerEventListMetaUpdatedConsumer new],
             [CCServerEventListMetaDeletedConsumer new],
        ];
}

- (CCList *)findNextListToProcess
{
    NSDate *minDate = [[NSDate date] dateByAddingTimeInterval:-(12 * 60 * 60)];
    
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCList entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lastUpdate < %@ or serverEvents.@count > 0", minDate];
    [fetchRequest setPredicate:predicate];
    
    NSMutableArray *lists = [[managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    if (error != nil) {
        CCLog(@"%@", error);
        return nil;
    }
    
    if ([lists count] == 0)
        return nil;
    
    NSSortDescriptor *eventNumberSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"serverEvents.@count" ascending:NO];
    NSSortDescriptor *lastUpdateSortDesciptor = [NSSortDescriptor sortDescriptorWithKey:@"lastUpdate" ascending:YES];
    [lists sortedArrayUsingDescriptors:@[eventNumberSortDescriptor, lastUpdateSortDesciptor]];
    
    CCList *list = [lists firstObject];
    
    if (list == nil)
        return nil;
    
    return list;
}

- (NSArray *)eventsList
{
    return @[@5, @6, @7, @8, @9, @10, @11];
}

- (void)fetchServerEventsWithList:(CCList *)list completionBlock:(void(^)(BOOL goOnSyncing))completionBlock
{
    _currentList = list;
    _currentConnection = [[CCLinotteAPI sharedInstance] fetchListEvents:list.identifier lastDate:list.lastEventDate completionBlock:^(BOOL success, NSArray *eventsDicts) {
        
        _currentList = nil;
        _currentConnection = nil;
        if (success == NO) {
            completionBlock(NO);
            return;
        }
        
        list.lastUpdate = [NSDate date];
        
        if ([eventsDicts count] == 0) {
            [[CCCoreDataStack sharedInstance] saveContext];
            completionBlock(NO);
            return;
        }
        
        CCLog(@"%lu events received", [eventsDicts count]);
        NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
        NSDate *lastEventDate = nil;
        for (NSDictionary *eventDict in eventsDicts) {
            CCServerEvent *serverEvent = [CCServerEvent insertInManagedObjectContext:managedObjectContext fromLinotteAPIDict:eventDict];
            [list addServerEventsObject:serverEvent];
            lastEventDate = serverEvent.date;
        }
        list.lastEventDate = lastEventDate;
        [[CCCoreDataStack sharedInstance] saveContext];
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
