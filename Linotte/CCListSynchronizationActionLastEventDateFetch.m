//
//  CCListSynchronizationActionLastEventDateFetch.m
//  Linotte
//
//  Created by stant on 07/03/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import "CCListSynchronizationActionLastEventDateFetch.h"

#import "CCModelChangeMonitor.h"

#import "CCLinotteCoreDataStack.h"
#import "CCLinotteAPI.h"
#import "CCLinotteEngineCoordinator.h"

#import "CCList.h"
#import "CCListZone.h"

@implementation CCListSynchronizationActionLastEventDateFetch
{
    CCList *_currentList;
    NSURLSessionTask *_currentConnection;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[CCModelChangeMonitor sharedInstance] addDelegate:self];
    }
    return self;
}

- (CCListZone *)listZoneToProcess:(CCList *)list
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCListZone entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"list = %@ and firstFetch = %@ and lastEventDate = nil", list, @NO];
    [fetchRequest setPredicate:predicate];
    
    NSArray *zones = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        CCLog(@"%@", error);
        return nil;
    }
    
    return [zones firstObject];
}

- (CCList *)findNextListToProcess
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCList entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"subquery(zones, $zone, $zone.firstFetch = %@ and $zone.lastEventDate = nil).@count != 0", @NO];
    [fetchRequest setFetchLimit:1];
    [fetchRequest setPredicate:predicate];
    
    NSArray *lists = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        CCLog(@"%@", error);
        return nil;
    }
    
    return [lists firstObject];
}

- (void)triggerWithList:(CCList *)list coordinates:(CLLocationCoordinate2D)coordinates completionBlock:(CCSynchronizationCompletionBlock)completionBlock
{
    CCListZone *zone = nil;
    if (list != nil && (zone = [self listZoneToProcess:list]) == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(NO, NO);
        });
        return;
    }
    
    list = list ?: [self findNextListToProcess];
    if (list == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(NO, NO);
        });
        return;
    }
    
    if (zone == nil) {
        zone = [self listZoneToProcess:list];
    }
    
    CCLog(@"Starting CCListSynchronizationActionLastEventDateFetch job");
    
    _currentConnection = [CCLEC.linotteAPI fetchListZoneLastEventDate:list.identifier geohash:zone.geohash success:^(NSDate *lastEventDate) {
        _currentList = nil;
        _currentConnection = nil;
        
        zone.lastEventDate = lastEventDate;
        [[CCLinotteCoreDataStack sharedInstance] saveContext];
        
        completionBlock(YES, NO);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        _currentList = nil;
        _currentConnection = nil;
        
        completionBlock(NO, NO);
    }];
}

#pragma mark - CCModelChangeMonitorDelegate

- (void)listWillRemove:(CCList *)list send:(BOOL)send
{
    if (_currentList == list)
        [_currentConnection cancel];
}

@end
