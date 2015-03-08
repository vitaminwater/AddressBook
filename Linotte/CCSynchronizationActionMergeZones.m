//
//  CCSynchronizationActionMergeZone.m
//  Linotte
//
//  Created by stant on 04/03/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import "CCSynchronizationActionMergeZones.h"

#import "CCLinotteCoreDataStack.h"
#import "CCModelChangeMonitor.h"
#import "CCLinotteAPI.h"
#import "CCLinotteEngineCoordinator.h"

#import "CCList.h"
#import "CCListZone.h"

#import "CCListSynchronizationActionInitialAddressFetch.h"
#import "CCListZoneSynchronizationActionConsumeEvents.h"

@implementation CCSynchronizationActionMergeZones
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

- (NSArray *)listZonesToProcess:(CCList *)list
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCListZone entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"list = %@ and needsMerge != nil", list];
    [fetchRequest setPredicate:predicate];
    
    NSArray *zones = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        CCLog(@"%@", error);
        return nil;
    }
    
    if ([zones count] == 0)
        return nil;
    
    return zones;
}

- (CCList *)findNextListToProcess
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCList entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"subquery(zones, $zone, $zone.needsMerge != nil).@count != 0"];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    NSArray *lists = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        CCLog(@"%@", error);
        return nil;
    }
    
    if ([lists count] == 0)
        return nil;
    
    return [lists firstObject];
}

- (void)triggerWithList:(CCList *)list coordinates:(CLLocationCoordinate2D)coordinates completionBlock:(CCSynchronizationCompletionBlock)completionBlock
{
    NSArray *zones = nil;
    if (list != nil && (zones = [self listZonesToProcess:list]) == nil) {
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
    
    if (zones == nil) {
        zones = [self listZonesToProcess:list];
    }
    
    CCLog(@"Stating CCSynchronizationActionMergeZones job");
    
    NSArray *geohashes = [zones valueForKeyPath:@"@distinctUnionOfObjects.needsMerge"];
    NSString *geohash = [geohashes firstObject];
    if ([self processFirstFetchZonesWithGeohash:geohash zones:zones list:list completionBlock:completionBlock]) {
        return;
    } else if ([self processZoneEventFetchWithGeohash:geohash zones:zones list:list completionBlock:completionBlock]) {
        return;
    } else {
        [self processZoneDiffAndMergeWithGeohash:geohash zones:zones list:list completionBlock:completionBlock];
        return;
    }
}

- (BOOL)processFirstFetchZonesWithGeohash:(NSString *)geohash zones:(NSArray *)zones list:(CCList *)list completionBlock:(CCSynchronizationCompletionBlock)completionBlock
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"needsMerge = %@ and firstFetch = %@", geohash, @(YES)];
    NSArray *firstFetchZones = [zones filteredArrayUsingPredicate:predicate];
    if ([firstFetchZones count] == 0) {
        return NO;
    }
    
    CCListZone *zone = [firstFetchZones firstObject];
    
    CCLog(@"processFirstFetchZonesWithGeohash %@", geohash);
    
    _currentList = list;
    _currentConnection = [CCLEC.linotteAPI fetchAddressesFromList:list.identifier geohash:zone.geohash excludeGeohashes:@[] lastAddressDate:zone.lastAddressFirstFetchDate limit:kCCAddressFetchLimit success:^(NSArray *addressesDicts) {
        _currentList = nil;
        _currentConnection = nil;
        
        initialAddressFetchProcess(list, zone, addressesDicts);
        
        completionBlock(YES, NO);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        _currentList = nil;
        _currentConnection = nil;
        completionBlock(NO, YES);
    }];
    return YES;
}

- (BOOL)processZoneEventFetchWithGeohash:(NSString *)geohash zones:(NSArray *)zones list:(CCList *)list completionBlock:(CCSynchronizationCompletionBlock)completionBlock
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"needsMerge = %@ and readyToMerge = %@ and firstFetch = %@", geohash, @(NO), @(NO)];
    NSArray *firstFetchZones = [zones filteredArrayUsingPredicate:predicate];
    if ([firstFetchZones count] == 0){
        return NO;
    }
    
    CCListZone *zone = [firstFetchZones firstObject];
    
    CCLog(@"processZoneEventFetchWithGeohash %@", zone.geohash);
    
    _currentList = list;
    _currentConnection = [CCLEC.linotteAPI fetchListEvents:list.identifier geohash:zone.geohash lastDate:zone.lastEventDate success:^(NSArray *eventsDicts) {
        _currentList = nil;
        _currentConnection = nil;
        
        fetchListEventsProcess(list, zone, eventsDicts);
        
        completionBlock(YES, NO);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        _currentList = nil;
        _currentConnection = nil;
        
        completionBlock(NO, YES);
    }];
    return YES;
}

- (void)processZoneDiffAndMergeWithGeohash:(NSString *)geohash zones:(NSArray *)zones list:(CCList *)list completionBlock:(CCSynchronizationCompletionBlock)completionBlock
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"needsMerge = %@ and readyToMerge = %@", geohash, @(YES)];
    NSArray *readyToMergeZones = [zones filteredArrayUsingPredicate:predicate];
    
    NSArray *subGeohashes = [readyToMergeZones valueForKeyPath:@"@distinctUnionOfObjects.geohash"];
    
    CCLog(@"processZoneDiffAndMergeWithGeohash %@ %@", geohash, [subGeohashes componentsJoinedByString:@", "]);

    _currentList = list;
    _currentConnection = [CCLEC.linotteAPI fetchAddressesFromList:list.identifier geohash:geohash excludeGeohashes:subGeohashes lastAddressDate:nil limit:50 success:^(NSArray *addressesDicts) {
        _currentList = nil;
        _currentConnection = nil;
        
        NSManagedObjectContext *managedOjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
        saveNewAddressesInList(list, addressesDicts, managedOjectContext);
        
        CCListZone *newZone = [CCListZone insertInManagedObjectContext:managedOjectContext];
        newZone.list = list;
        newZone.geohash = geohash;
        newZone.lastUpdate = [NSDate date];
        newZone.lastEventDate = [readyToMergeZones valueForKeyPath:@"@max.lastEventDate"];
        newZone.firstFetchValue = NO;
        [newZone updateNAddresses:managedOjectContext];
        
        for (CCListZone *oldZone in readyToMergeZones) {
            [managedOjectContext deleteObject:oldZone];
        }
        
        [[CCLinotteCoreDataStack sharedInstance] saveContext];
        
        completionBlock(YES, NO);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        _currentList = nil;
        _currentConnection = nil;
        
        completionBlock(NO, YES);
    }];
    return;
}

#pragma mark - CCModelChangeMonitorDelegate

- (void)listWillRemove:(CCList *)list send:(BOOL)send
{
    if (_currentList == list)
        [_currentConnection cancel];
}

@end
