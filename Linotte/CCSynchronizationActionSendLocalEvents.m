//
//  CCSynchronizationSendLocalEvents.m
//  Linotte
//
//  Created by stant on 10/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCSynchronizationActionSendLocalEvents.h"

#import "CCLinotteAPI.h"

#import "CCCoreDataStack.h"

#import "CCList.h"
#import "CCAddress.h"
#import "CCLocalEvent.h"

@implementation CCSynchronizationActionSendLocalEvents

- (void)triggerWithList:(CCList *)list coordinates:(CLLocationCoordinate2D)coordinates completionBlock:(void(^)(BOOL goOnSyncing))completionBlock
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCLocalEvent entityName]];
    fetchRequest.fetchLimit = 1;
    
    NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    [fetchRequest setSortDescriptors:@[dateSortDescriptor]];
    
    NSArray *events = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    
    if ([events count])
        [self sendEvent:[events firstObject] completionBlock:completionBlock];
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(NO);
        });
    }
}

- (void)sendEvent:(CCLocalEvent *)event completionBlock:(void(^)(BOOL done))completionBlock
{
    void (^eventSendRequestEnd)(BOOL success) = ^(BOOL success) {
        if (success) {
            NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
            [managedObjectContext deleteObject:event];
            [[CCCoreDataStack sharedInstance] saveContext];
        }
        completionBlock(YES);
    };
    
    switch (event.eventValue) {
        case CCLocalEventAddressCreated:
        {
            [[CCLinotteAPI sharedInstance] createAddress:event.parameters completionBlock:^(BOOL success, NSString *identifier) {
                if (success) {
                    [self setValue:identifier forKey:@"address" forEventsPredicate:[NSPredicate predicateWithFormat:@"localAddressIdentifier = %@", event.localAddressIdentifier]];
                    
                    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
                    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"localIdentifier = %@", event.localAddressIdentifier];
                    [fetchRequest setPredicate:predicate];
                    NSArray *addresses = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
                    
                    if ([addresses count] != 0) {
                        CCAddress *address = [addresses firstObject];
                        address.identifier = identifier;
                    }
                    
                    [[CCCoreDataStack sharedInstance] saveContext];
                }
                eventSendRequestEnd(success);
            }];
        }
            break;
        case CCLocalEventListCreated:
        {
            [[CCLinotteAPI sharedInstance] createList:event.parameters completionBlock:^(BOOL success, NSString *identifier) {
                if (success) {
                    [self setValue:identifier forKey:@"list" forEventsPredicate:[NSPredicate predicateWithFormat:@"localListIdentifier = %@", event.localListIdentifier]];
                    
                    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
                    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCList entityName]];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"localIdentifier = %@", event.localListIdentifier];
                    [fetchRequest setPredicate:predicate];
                    NSArray *lists = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
                    
                    if ([lists count] != 0) {
                        CCList *list = [lists firstObject];
                        list.identifier = identifier;
                    }
                    
                    [[CCCoreDataStack sharedInstance] saveContext];
                }
                eventSendRequestEnd(success);
            }];
        }
            break;
        case CCLocalEventListRemoved:
        {
            [[CCLinotteAPI sharedInstance] removeList:event.parameters completionBlock:eventSendRequestEnd];
        }
            break;
        case CCLocalEventAddressMovedToList:
        {
            [[CCLinotteAPI sharedInstance] addAddressToList:event.parameters completionBlock:eventSendRequestEnd];
        }
            break;
        case CCLocalEventAddressMovedFromList:
        {
            [[CCLinotteAPI sharedInstance] removeAddressFromList:event.parameters completionBlock:eventSendRequestEnd];
        }
            break;
        case CCLocalEventAddressUpdated:
        {
            [[CCLinotteAPI sharedInstance] updateAddress:event.parameters completionBlock:eventSendRequestEnd];
        }
            break;
        case CCLocalEventListUpdated:
        {
            [[CCLinotteAPI sharedInstance] updateList:event.parameters completionBlock:eventSendRequestEnd];
        }
            break;
        case CCLocalEventAddressUserDataUpdated:
        {
            [[CCLinotteAPI sharedInstance] updateAddressUserData:event.parameters completionBlock:eventSendRequestEnd];
        }
            break;
        default:
            break;
    }
}

- (void)setValue:(NSString *)value forKey:(NSString *)key forEventsPredicate:(NSPredicate *)predicate
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCLocalEvent entityName]];
    [fetchRequest setPredicate:predicate];
    
    NSArray *addressEvents = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    for (CCLocalEvent *addressEvent in addressEvents) {
        NSMutableDictionary *parameters = [addressEvent.parameters mutableCopy];
        parameters[key] = value;
        addressEvent.parameters = parameters;
    }
}

@end
