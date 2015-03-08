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

NSDate *getLastAddressDate(NSArray *addressesDicts) {
    NSDate *lastAddressDate = nil;
    
    for (NSDictionary *addressDict in addressesDicts) {
        NSDate *dateCreated = [CCLEC.linotteAPI dateFromString:addressDict[@"date_created"]];
        if (lastAddressDate == nil || [lastAddressDate compare:dateCreated] == NSOrderedAscending) {
            lastAddressDate = dateCreated;
        }
    }
    return lastAddressDate;
}

void saveNewAddressesInList(CCList *list, NSArray *addressesDicts, NSManagedObjectContext *managedObjectContext) {
    NSMutableArray *addresses = [[CCAddress insertOrUpdateInManagedObjectContext:managedObjectContext fromLinotteAPIDictArray:addressesDicts list:nil] mutableCopy];
    
    NSPredicate *metaForListPredicate = [NSPredicate predicateWithFormat:@"list != nil"];
    
    NSArray *addressDictIdentifiers = [addressesDicts valueForKeyPath:@"@unionOfObjects.identifier"];
    for (CCAddress *address in addresses) {
        NSUInteger addressDictIndex = [addressDictIdentifiers indexOfObject:address.identifier];
        
        if (addressDictIndex == NSNotFound)
            continue;
        
        NSDictionary *addressDict = addressesDicts[addressDictIndex];
        NSArray *metaDictArray = addressDict[@"metas"];
        
        NSArray *addressMetas = [CCAddressMeta insertInManagedObjectContext:managedObjectContext fromLinotteAPIDictArray:metaDictArray];
        NSSet *addressMetasSet = [NSSet setWithArray:addressMetas];
        [list addAddressMetas:[addressMetasSet filteredSetUsingPredicate:metaForListPredicate]];
        [address addMetas:addressMetasSet];
    }
    
    [[CCModelChangeMonitor sharedInstance] addresses:addresses willMoveToList:list send:NO];
    [list addAddresses:[NSSet setWithArray:addresses]];
    [[CCLinotteCoreDataStack sharedInstance] saveContext];
    [[CCModelChangeMonitor sharedInstance] addresses:addresses didMoveToList:list send:NO];
}

void initialAddressFetchProcess(CCList *list, CCListZone *zone, NSArray *addressesDicts) {
    CCLog(@"Fetching zone %@", zone.geohash);
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    
    NSDate *lastAddressFirstFetchDate = getLastAddressDate(addressesDicts);
    zone.lastAddressFirstFetchDate = lastAddressFirstFetchDate;
    
    saveNewAddressesInList(list, addressesDicts, managedObjectContext);
    
    if ([addressesDicts count] != kCCAddressFetchLimit) { // finish
        if (zone.needsMerge != nil)
            zone.readyToMergeValue = YES;
        zone.firstFetchValue = NO;
        zone.lastAddressFirstFetchDate = nil;
        zone.lastEventDate = nil;
        zone.lastUpdate = [NSDate date];
        [zone updateNAddresses:managedObjectContext];
        CCLog(@"Zone %@ completed", zone.geohash);
    }
    
    [[CCLinotteCoreDataStack sharedInstance] saveContext];
}

@implementation CCListSynchronizationActionInitialAddressFetch
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

- (void)triggerWithList:(CCList *)list coordinates:(CLLocationCoordinate2D)coordinates completionBlock:(CCSynchronizationCompletionBlock)completionBlock
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
        if (zone.firstFetchValue == NO) {
            continue;
        }
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
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        completionBlock(NO, NO);
    });
}

#pragma mark - CCModelChangeMonitorDelegate

- (void)listWillRemove:(CCList *)list send:(BOOL)send
{
    if (_currentList == list)
        [_currentConnection cancel];
}

@end
