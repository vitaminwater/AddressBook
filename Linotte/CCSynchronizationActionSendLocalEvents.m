//
//  CCSynchronizationSendLocalEvents.m
//  Linotte
//
//  Created by stant on 10/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCSynchronizationActionSendLocalEvents.h"

#import "CCLinotteAPI.h"
#import "CCLinotteEngineCoordinator.h"
#import "CCLinotteCoreDataStack.h"

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
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    
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
    void (^deleteCurrentRequestBlock)() = ^() {
        NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
        [managedObjectContext deleteObject:event];
        [[CCLinotteCoreDataStack sharedInstance] saveContext];
        completionBlock(YES, NO);
    };
    
    void (^eventSendRequestSuccessBlock)() = ^() {
        deleteCurrentRequestBlock();
    };
    
    void (^eventSendRequestFailureBlock)(NSURLSessionDataTask *task, NSError *error) = ^(NSURLSessionDataTask *task, NSError *error) {
        if (error.code == 401) {
            deleteCurrentRequestBlock();
        } else {
            completionBlock(NO, YES);
        }
    };
    
    switch (event.eventValue) {
        case CCLocalEventAddressCreated:
        {
            [CCLEC.linotteAPI createAddress:event.parameters success:^(NSString *identifier, NSInteger statusCode) {
                [self setValue:identifier forKey:@"address" forEventsPredicate:[NSPredicate predicateWithFormat:@"localAddressIdentifier = %@", event.localAddressIdentifier]];
                
                NSError *error = nil;
                NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
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
                
                [[CCLinotteCoreDataStack sharedInstance] saveContext];
                
                deleteCurrentRequestBlock();
            } failure:eventSendRequestFailureBlock];
        }
            break;
        case CCLocalEventListCreated:
        {
            [CCLEC.linotteAPI createList:event.parameters success:^(NSString *identifier) {
                [self setValue:identifier forKey:@"list" forEventsPredicate:[NSPredicate predicateWithFormat:@"localListIdentifier = %@", event.localListIdentifier]];
                
                NSError *error = nil;
                NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
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
                
                [[CCLinotteCoreDataStack sharedInstance] saveContext];
                
                deleteCurrentRequestBlock();
            } failure:eventSendRequestFailureBlock];
        }
            break;
        case CCLocalEventListRemoved:
        {
            [CCLEC.linotteAPI removeList:event.parameters success:eventSendRequestSuccessBlock failure:eventSendRequestFailureBlock];
        }
            break;
        case CCLocalEventAddressMovedToList:
        {
            [CCLEC.linotteAPI addAddressToList:event.parameters success:eventSendRequestSuccessBlock failure:eventSendRequestFailureBlock];
        }
            break;
        case CCLocalEventAddressMovedFromList:
        {
            [CCLEC.linotteAPI removeAddressFromList:event.parameters success:eventSendRequestSuccessBlock failure:eventSendRequestFailureBlock];
        }
            break;
        case CCLocalEventAddressUpdated:
        {
            [CCLEC.linotteAPI updateAddress:event.parameters success:eventSendRequestSuccessBlock failure:eventSendRequestFailureBlock];
        }
            break;
        case CCLocalEventListUpdated:
        {
            [CCLEC.linotteAPI updateList:event.parameters success:eventSendRequestSuccessBlock failure:eventSendRequestFailureBlock];
        }
            break;
        case CCLocalEventAddressUserDataUpdated:
        {
            [CCLEC.linotteAPI updateAddressUserData:event.parameters success:eventSendRequestSuccessBlock failure:eventSendRequestFailureBlock];
        }
            break;
        case CCLocalEventListUserDataUpdated:
        {
            [CCLEC.linotteAPI updateListUserData:event.parameters success:eventSendRequestSuccessBlock failure:eventSendRequestFailureBlock];
        }
            break;
        case CCLocalEventListAdded:
        {
            [CCLEC.linotteAPI addList:event.parameters success:eventSendRequestSuccessBlock failure:eventSendRequestFailureBlock];
        }
            break;
        case CCLocalEventAddressMetaAdded:
        {
            [CCLEC.linotteAPI createAddressMeta:event.parameters success:eventSendRequestSuccessBlock failure:eventSendRequestFailureBlock];
        }
            break;
        default:
            break;
    }
}

- (void)setValue:(NSString *)value forKey:(NSString *)key forEventsPredicate:(NSPredicate *)predicate
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
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
