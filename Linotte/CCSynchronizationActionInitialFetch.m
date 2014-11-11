//
//  CCSynchronizationActionInitialFetch.m
//  Linotte
//
//  Created by stant on 10/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCSynchronizationActionInitialFetch.h"

#import "CCCoreDataStack.h"

#import "CCLinotteAPI.h"

#import "CCModelChangeMonitor.h"

#import "CCList.h"
#import "CCListZone.h"
#import "CCAddress.h"

@implementation CCSynchronizationActionInitialFetch

- (BOOL)listNeedProcess:(CCList *)list
{
    NSUInteger totalNAddresses = [[list.zones valueForKeyPath:@"@sum.nAddresses"] unsignedIntegerValue];
    NSUInteger currentNaddresses = [list.addresses count];
    return currentNaddresses < totalNAddresses && currentNaddresses < kCCMaxAddressesForList;
}

- (CCList *)findNextListToProcess
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCList entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"addresses.@count < zones.@sum.nAddresses and addresses.@count < %@", @(kCCMaxAddressesForList)];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    NSArray *lists = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    return [lists firstObject];
}

- (void)triggerWithList:(CCList *)list coordinates:(CLLocationCoordinate2D)coordinates completionBlock:(void(^)(BOOL done))completionBlock
{
    if (list != nil && [self listNeedProcess:list] == NO) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(NO);
        });
        return;
    }
    
    list = list ?: [self findNextListToProcess];
    if (list == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(NO);
        });
        return;
    }
    
    NSArray *sortedZones = [list getListZonesSortedByDistanceFromLocation:coordinates];
    
    NSLog(@"Starting CCListSynchronizationActionInitialAddressFetch job");
    for (CCListZone *zone in sortedZones) {
        if (zone.firstFetchValue == NO)
            continue;
        [[CCLinotteAPI sharedInstance] fetchAddressesFromList:list.identifier geohash:zone.geohash lastAddressDate:zone.lastAddressFirstFetchDate limit:kCCAddressFetchLimit completionBlock:^(BOOL success, NSArray *addressesDicts) {
            if (success == NO) {
                completionBlock(YES);
                return;
            }
            NSLog(@"Fetching zone %@", zone.geohash);
            NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
            if ([addressesDicts count] != kCCAddressFetchLimit) {
                zone.firstFetchValue = NO;
                NSLog(@"Zone %@ completed", zone.geohash);
            }
            NSDate *lastAddressFirstFetchDate = nil;
            NSMutableArray *addresses = [@[] mutableCopy];
            for (NSDictionary *addressDict in addressesDicts) {
                CCAddress *address = [CCAddress insertInManagedObjectContext:managedObjectContext fromLinotteAPIDict:addressDict];
                [addresses addObject:address];
                lastAddressFirstFetchDate = [[CCLinotteAPI sharedInstance] dateFromString:addressDict[@"date_created"]];
            }
            
            [[CCModelChangeMonitor sharedInstance] addresses:addresses willMoveToList:list send:NO];
            [list addAddresses:[NSSet setWithArray:addresses]];
            [[CCCoreDataStack sharedInstance] saveContext];
            [[CCModelChangeMonitor sharedInstance] addresses:addresses didMoveToList:list send:NO];
            
            list.lastDateUpdate = [NSDate date];
            
            zone.lastAddressFirstFetchDate = lastAddressFirstFetchDate;
            [[CCCoreDataStack sharedInstance] saveContext];
            completionBlock(YES);
        }];
        break;
    }
}

@end
