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

- (void)triggerWithList:(CCList *)list coordinates:(CLLocationCoordinate2D)coordinates completionBlock:(void(^)(BOOL goOnSyncing, BOOL error))completionBlock
{
    if (list != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(NO, NO);
        });
        return;
    }
    
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCLocalEvent entityName]];
    fetchRequest.fetchLimit = 1;
    
    NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    [fetchRequest setSortDescriptors:@[dateSortDescriptor]];
    
    NSArray *events = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        CCLog(@"%@", error);
        return;
    }
    
    if ([events count])
        [self sendEvent:[events firstObject] completionBlock:completionBlock];
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(NO, NO);
        });
    }
}

- (void)sendEvent:(CCLocalEvent *)event completionBlock:(void(^)(BOOL done, BOOL error))completionBlock
{
    void (^eventSendRequestEnd)(BOOL success, NSInteger statusCode) = ^(BOOL success, NSInteger statusCode) {
        if (success || statusCode == 401) {
            NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
            [managedObjectContext deleteObject:event];
            [[CCCoreDataStack sharedInstance] saveContext];
            completionBlock(YES, NO);
        } else {
            completionBlock(NO, YES);
        }
    };
    
    switch (event.eventValue) {
        case CCLocalEventAddressCreated:
        {
            [[CCLinotteAPI sharedInstance] createAddress:event.parameters completionBlock:^(BOOL success, NSString *identifier, NSInteger statusCode) {
                if (success) {
                    [self setValue:identifier forKey:@"address" forEventsPredicate:[NSPredicate predicateWithFormat:@"localAddressIdentifier = %@", event.localAddressIdentifier]];
                    
                    NSError *error = nil;
                    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
                    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"localIdentifier = %@", event.localAddressIdentifier];
                    [fetchRequest setPredicate:predicate];
                    NSArray *addresses = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
                    
                    if (error != nil) {
                        CCLog(@"%@", error);
                        return;
                    }
                    
                    if ([addresses count] != 0) {
                        CCAddress *address = [addresses firstObject];
                        address.identifier = identifier;
                    }
                    
                    [[CCCoreDataStack sharedInstance] saveContext];
                }
                eventSendRequestEnd(success, statusCode);
            }];
        }
            break;
        case CCLocalEventListCreated:
        {
            [[CCLinotteAPI sharedInstance] createList:event.parameters completionBlock:^(BOOL success, NSString *identifier, NSInteger statusCode) {
                if (success) {
                    [self setValue:identifier forKey:@"list" forEventsPredicate:[NSPredicate predicateWithFormat:@"localListIdentifier = %@", event.localListIdentifier]];
                    
                    NSError *error = nil;
                    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
                    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCList entityName]];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"localIdentifier = %@", event.localListIdentifier];
                    [fetchRequest setPredicate:predicate];
                    NSArray *lists = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
                    
                    if (error != nil) {
                        CCLog(@"%@", error);
                        return;
                    }
                    
                    if ([lists count] != 0) {
                        CCList *list = [lists firstObject];
                        list.identifier = identifier;
                    }
                    
                    [[CCCoreDataStack sharedInstance] saveContext];
                }
                eventSendRequestEnd(success, statusCode);
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
        case CCLocalEventListUserDataUpdated:
        {
            [[CCLinotteAPI sharedInstance] updateListUserData:event.parameters completionBlock:eventSendRequestEnd];
        }
            break;
        case CCLocalEventListAdded:
        {
            [[CCLinotteAPI sharedInstance] addList:event.parameters completionBlock:eventSendRequestEnd];
        }
            break;
        case CCLocalEventAddressMetaAdded:
        {
            [[CCLinotteAPI sharedInstance] createAddressMeta:event.parameters completionBlock:eventSendRequestEnd];
        }
            break;
        default:
            break;
    }
}

- (void)setValue:(NSString *)value forKey:(NSString *)key forEventsPredicate:(NSPredicate *)predicate
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCLocalEvent entityName]];
    [fetchRequest setPredicate:predicate];
    
    NSArray *addressEvents = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        CCLog(@"%@", error);
        return;
    }
    
    for (CCLocalEvent *addressEvent in addressEvents) {
        NSMutableDictionary *parameters = [addressEvent.parameters mutableCopy];
        parameters[key] = value;
        addressEvent.parameters = parameters;
    }
}

@end
