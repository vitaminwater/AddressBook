//
//  CCHomeListViewModel.m
//  Linotte
//
//  Created by stant on 13/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCHomeListViewModel.h"

#import "CCCoreDataStack.h"
#import "CCDictStackCache.h"

#import "CCListViewContentProvider.h"

#import "CCAddress.h"
#import "CCList.h"

#define kCCHomeListViewModelUnownedListsKey @"kCCHomeListViewModelUnownedListsKey"
#define kCCHomeListViewModelUnownedAddressesKey @"kCCHomeListViewModelUnownedAddressesKey"
#define kCCHomeListViewModelAddressMovedFromListsKey @"kCCHomeListViewModelAddressMovedFromListsKey"

@implementation CCHomeListViewModel

@synthesize provider;

#pragma mark CCListViewModelProtocol methods

- (void)loadListItems
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    // Addresses
    {
        NSError *error = nil;
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY lists.owned = %@", @YES];
        [fetchRequest setPredicate:predicate];
        
        NSArray *addresses = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if (error != nil)
            CCLog(@"%@", error);
        else
            [self.provider addAddresses:addresses];
    }
    
    // Lists
    {
        NSError *error = nil;
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCList entityName]];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"owned = %@", @NO];
        [fetchRequest setPredicate:predicate];
        
        NSArray *lists = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if (error != nil)
            CCLog(@"%@", error);
        else {
            for (CCList *list in lists) {
                [self.provider addList:list];
            }
        }
    }
}

#pragma mark CCModelChangeMonitorDelegate methods

- (void)addressesDidUpdate:(NSArray *)addresses send:(BOOL)send
{
    [self.provider refreshListItemContentsForObjects:[self ownedAddresses:addresses]];
}

- (void)addressesDidUpdateUserData:(NSArray *)addresses send:(BOOL)send
{
    [self.provider refreshListItemContentsForObjects:[self ownedAddresses:addresses]];
}

- (void)listDidAdd:(CCList *)list send:(BOOL)send
{
    if (list.ownedValue == NO) {
        [self.provider addList:list];
    }
}

- (void)listWillRemove:(CCList *)list send:(BOOL)send
{
    if (list.ownedValue == NO) {
        [self.provider removeList:list];
    }
}

- (void)listDidUpdate:(CCList *)list send:(BOOL)send
{
    if (list.ownedValue == NO)
        [self.provider refreshListItemContentForObject:list];
}

- (void)addresses:(NSArray *)addresses willMoveToList:(CCList *)list send:(BOOL)send
{
    if (list.ownedValue == YES) {
        NSArray *unownedAddresses = [self unownedAddresses:addresses];
        [self.provider addAddresses:unownedAddresses];
    } else {
        [self.provider addAddresses:addresses toList:list];
    }
}

- (void)addresses:(NSArray *)addresses didMoveFromList:(CCList *)list send:(BOOL)send
{
    if (list.ownedValue == YES) {
        NSArray *unownedAddresses = [self unownedAddresses:addresses];
        [self.provider removeAddresses:unownedAddresses];
    } else {
        [self.provider removeAddresses:addresses fromList:list];
    }
}

- (void)listDidUpdateUserData:(CCList *)list send:(BOOL)send
{
    if (list.ownedValue == NO)
        [self.provider refreshListItemContentForObject:list];
}

#pragma mark - utility methods

- (NSArray *)ownedAddresses:(NSArray *)addresses
{
    NSPredicate *ownedAddressesPredicate = [NSPredicate predicateWithFormat:@"SUBQUERY(lists, $list, $list.owned = %@).@count != 0", @YES];
    NSArray *ownedAddresses = [addresses filteredArrayUsingPredicate:ownedAddressesPredicate];
    return ownedAddresses;
}

- (NSArray *)unownedAddresses:(NSArray *)addresses
{
    NSPredicate *unownedAddressesPredicate = [NSPredicate predicateWithFormat:@"SUBQUERY(lists, $list, $list.owned = %@).@count = 0", @YES];
    NSArray *unownedAddresses = [addresses filteredArrayUsingPredicate:unownedAddressesPredicate];
    return unownedAddresses;
}

- (NSArray *)unownedLists:(NSArray *)addresses
{
    NSPredicate *unownedListsPredicate = [NSPredicate predicateWithFormat:@"SELF.owned = %@", @NO];
    NSArray *lists = [addresses valueForKeyPath:@"@distinctUnionOfArrays.lists"];
    NSArray *unownedLists = [lists filteredArrayUsingPredicate:unownedListsPredicate];
    return unownedLists;
}

@end
