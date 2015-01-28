//
//  CCSynchronizationActionInitialFetch.m
//  Linotte
//
//  Created by stant on 10/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListSynchronizationActionInitialAddressFetch.h"

#import "CCLinotteCoreDataStack.h"

#import "CCLinotteAPI.h"
#import "CCLinotteEngineCoordinator.h"

#import "CCModelChangeMonitor.h"

#import "CCList.h"
#import "CCListZone.h"
#import "CCAddress.h"
#import "CCAddressMeta.h"

@implementation CCListSynchronizationActionInitialAddressFetch
{
    CCList *_currentList;
    NSURLSessionTask *_currentConnection;
}

- (BOOL)listNeedProcess:(CCList *)list
{
    NSUInteger totalNAddresses = [[list.zones valueForKeyPath:@"@sum.nAddresses"] unsignedIntegerValue];
    NSUInteger currentNaddresses = [list.addresses count];
    return currentNaddresses < totalNAddresses && currentNaddresses < kCCMaxAddressesForList;
}

- (CCList *)findNextListToProcess
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCList entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier != nil and addresses.@count < zones.@sum.nAddresses and addresses.@count < %@ and SUBQUERY(zones, $zone, $zone.firstFetch = %@).@count != 0", @(kCCMaxAddressesForList), @YES];
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

- (void)triggerWithList:(CCList *)list coordinates:(CLLocationCoordinate2D)coordinates completionBlock:(void(^)(BOOL goOnSyncing, BOOL error))completionBlock
{
    if (list != nil && [self listNeedProcess:list] == NO) {
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
    
    NSArray *sortedZones = [list getListZonesSortedByDistanceFromLocation:coordinates];
    
    CCLog(@"Starting CCListSynchronizationActionInitialAddressFetch job");
    
    for (CCListZone *zone in sortedZones) {
        if (zone.firstFetchValue == NO)
            continue;
        _currentList = list;
        _currentConnection = [CCLEC.linotteAPI fetchAddressesFromList:list.identifier geohash:zone.geohash lastAddressDate:zone.lastAddressFirstFetchDate limit:kCCAddressFetchLimit success:^(NSArray *addressesDicts) {
            BOOL finished = NO;
            CCLog(@"Fetching zone %@", zone.geohash);
            NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
            if ([addressesDicts count] != kCCAddressFetchLimit) {
                finished = YES;
                CCLog(@"Zone %@ completed", zone.geohash);
            }
            
            NSMutableArray *addresses = [[CCAddress insertOrUpdateInManagedObjectContext:managedObjectContext fromLinotteAPIDictArray:addressesDicts list:nil] mutableCopy];
            NSDate *lastAddressFirstFetchDate = [self getLastAddressDate:addressesDicts];
            
            NSArray *addressDictIdentifiers = [addressesDicts valueForKeyPath:@"@unionOfObjects.identifier"];
            for (CCAddress *address in addresses) {
                NSUInteger addressDictIndex = [addressDictIdentifiers indexOfObject:address.identifier];
                
                if (addressDictIndex == NSNotFound)
                    continue;
                
                NSDictionary *addressDict = addressesDicts[addressDictIndex];
                NSArray *metaDictArray = addressDict[@"metas"];
                
                NSArray *addressMetas = [CCAddressMeta insertInManagedObjectContext:managedObjectContext fromLinotteAPIDictArray:metaDictArray];
                [list addAddressMetas:[NSSet setWithArray:addressMetas]];
                [address addMetas:[NSSet setWithArray:addressMetas]];
            }
            
            [[CCModelChangeMonitor sharedInstance] addresses:addresses willMoveToList:list send:NO];
            [list addAddresses:[NSSet setWithArray:addresses]];
            [[CCLinotteCoreDataStack sharedInstance] saveContext];
            [[CCModelChangeMonitor sharedInstance] addresses:addresses didMoveToList:list send:NO];
            
            zone.lastAddressFirstFetchDate = lastAddressFirstFetchDate;
            
            [[CCLinotteCoreDataStack sharedInstance] saveContext];
            
            if (finished == YES) {
                _currentConnection = [CCLEC.linotteAPI fetchListZoneLastEventDate:list.identifier geohash:zone.geohash success:^(NSDate *lastEventDate) {
                    _currentList = nil;
                    _currentConnection = nil;
                    
                    zone.firstFetchValue = NO;
                    zone.lastAddressFirstFetchDate = nil;
                    zone.lastEventDate = lastEventDate;
                    zone.lastUpdate = [NSDate date];
                    [[CCLinotteCoreDataStack sharedInstance] saveContext];
                    
                    completionBlock(YES, NO);
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    _currentList = nil;
                    _currentConnection = nil;
                    
                    completionBlock(NO, NO);
                }];
            } else {
                _currentList = nil;
                _currentConnection = nil;
                completionBlock(YES, NO);
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            _currentList = nil;
            _currentConnection = nil;
            completionBlock(NO, YES);
        }];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        completionBlock(NO, NO);
    });
}

- (NSDate *)getLastAddressDate:(NSArray *)addressDicts
{
    NSDate *lastAddressDate = nil;
    
    for (NSDictionary *addressDict in addressDicts) {
        NSDate *dateCreated = [CCLEC.linotteAPI dateFromString:addressDict[@"date_created"]];
        if (lastAddressDate == nil || [lastAddressDate compare:dateCreated] == NSOrderedAscending) {
            lastAddressDate = dateCreated;
        }
    }
    return lastAddressDate;
}

#pragma mark - CCModelChangeMonitorDelegate

- (void)listWillRemove:(CCList *)list send:(BOOL)send
{
    if (_currentList == list)
        [_currentConnection cancel];
}

@end
