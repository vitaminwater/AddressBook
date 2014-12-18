//
//  CCHomeListViewModel.m
//  Linotte
//
//  Created by stant on 13/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCBookAndNotifiedListViewModel.h"

#import "NSArray+CCArray.h"

#import "CCLinotteCoreDataStack.h"
#import "CCDictStackCache.h"

#import "CCListViewContentProvider.h"

#import "CCAddress.h"
#import "CCList.h"

#define kCCHomeListViewModelUnnotifiedAddressesKey @"kCCHomeListViewModelUnnotifiedAddressesKey"
#define kCCHomeListViewModelNotifiedAddressesKey @"kCCHomeListViewModelNotifiedAddressesKey"
#define kCCHomeListViewModelAddressMovedFromListsKey @"kCCHomeListViewModelAddressMovedFromListsKey"

@implementation CCBookAndNotifiedListViewModel

@synthesize provider;

#pragma mark CCListViewModelProtocol methods

- (void)loadListItems:(NSString *)filterText
{
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    
    // Addresses
    {
        NSError *error = nil;
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
        
        NSPredicate *predicate;
        if (filterText != nil) {
            predicate = [NSPredicate predicateWithFormat:@"notify = %@ AND ANY lists.notify = %@ AND name CONTAINS[c] %@", @YES, @YES, filterText];
        } else {
            predicate = [NSPredicate predicateWithFormat:@"notify = %@ AND ANY lists.notify = %@", @YES, @YES];
        }
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
        
        NSArray *lists = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if (error != nil)
            CCLog(@"%@", error);
        else {
            [self.provider addLists:lists];
        }
    }
}

#pragma mark CCModelChangeMonitorDelegate methods

- (void)addressesDidUpdate:(NSArray *)addresses send:(BOOL)send
{
    [self.provider refreshListItemContentsForObjects:[self notifiedAddresses:addresses]];
}

- (void)addressesWillUpdateUserData:(NSArray *)addresses send:(BOOL)send
{
    [self.cache pushCacheEntry:kCCHomeListViewModelNotifiedAddressesKey value:[self notifiedAddresses:addresses]];
}

- (void)addressesDidUpdateUserData:(NSArray *)addresses send:(BOOL)send
{
    NSArray *preNotifiedAddresses = [self.cache popCacheEntry:kCCHomeListViewModelNotifiedAddressesKey];
    NSArray *notifiedAddresses = [self notifiedAddresses:addresses];
    
    NSArray *addressesToAdd = [notifiedAddresses arrayByRemovingObjectsFromArray:preNotifiedAddresses];
    NSArray *addressesToRemove = [preNotifiedAddresses arrayByRemovingObjectsFromArray:notifiedAddresses];
    NSArray *addressesToRefresh = [[addresses arrayByRemovingObjectsFromArray:addressesToAdd] arrayByRemovingObjectsFromArray:addressesToRemove];
    
    [self.provider removeAddresses:addressesToRemove];
    [self.provider addAddresses:addressesToAdd];
    [self.provider refreshListItemContentsForObjects:addressesToRefresh];
}

- (void)listsDidAdd:(NSArray *)lists send:(BOOL)send
{
    [self.provider addLists:lists];
}

- (void)listsWillRemove:(NSArray *)lists send:(BOOL)send
{
    [self.cache pushCacheEntry:kCCHomeListViewModelNotifiedAddressesKey value:[self notifiedAddressesForLists:lists]];
    [self.provider removeLists:lists];
}

- (void)listsDidRemove:(NSArray *)identifiers send:(BOOL)send
{
    NSArray *preNotifiedAddresses = [self.cache popCacheEntry:kCCHomeListViewModelNotifiedAddressesKey];
    NSArray *notifiedAddresses = [self notifiedAddresses:preNotifiedAddresses];
    
    NSArray *addressesToRemove = [preNotifiedAddresses arrayByRemovingObjectsFromArray:notifiedAddresses];
    [self.provider removeAddresses:addressesToRemove];
}

- (void)listsDidUpdate:(NSArray *)lists send:(BOOL)send
{
    [self.provider refreshListItemContentsForObjects:lists];
}

- (void)addresses:(NSArray *)addresses didMoveToList:(CCList *)list send:(BOOL)send
{
    NSArray *notifiedAddresses = [self notifiedAddresses:addresses];
    [self.provider addAddresses:notifiedAddresses];
    [self.provider addAddresses:addresses toList:list];
}

- (void)addresses:(NSArray *)addresses willMoveFromList:(CCList *)list send:(BOOL)send;
{
    if (list.notifyValue == YES) {
        [self.cache pushCacheEntry:kCCHomeListViewModelNotifiedAddressesKey value:[self notifiedAddresses:addresses]];
    }
}

- (void)addresses:(NSArray *)addresses didMoveFromList:(CCList *)list send:(BOOL)send
{
    if (list.notifyValue == YES) {
        NSArray *preNotifiedAddresses = [self.cache popCacheEntry:kCCHomeListViewModelNotifiedAddressesKey];
        NSArray *notifiedAddresses = [self notifiedAddresses:addresses];
        
        NSArray *addressesToAdd = [notifiedAddresses arrayByRemovingObjectsFromArray:preNotifiedAddresses];
        NSArray *addressesToRemove = [preNotifiedAddresses arrayByRemovingObjectsFromArray:notifiedAddresses];
        NSArray *addressesToRefresh = [[addresses arrayByRemovingObjectsFromArray:addressesToAdd] arrayByRemovingObjectsFromArray:addressesToRemove];

        [self.provider removeAddresses:addressesToRemove];
        [self.provider addAddresses:addressesToAdd];
        [self.provider refreshListItemContentsForObjects:addressesToRefresh];
    }
    [self.provider removeAddresses:addresses fromList:list];
}

- (void)listsWillUpdateUserData:(NSArray *)lists send:(BOOL)send
{
    NSArray *notifiedAddresses = [self notifiedAddressesForLists:lists];
    [self.cache pushCacheEntry:kCCHomeListViewModelNotifiedAddressesKey value:notifiedAddresses];
}

- (void)listsDidUpdateUserData:(NSArray *)lists send:(BOOL)send
{
    NSArray *preNotifiedAddresses = [self.cache popCacheEntry:kCCHomeListViewModelNotifiedAddressesKey];
    NSArray *notifiedAddresses = [self notifiedAddressesForLists:lists];
    
    NSArray *addressesToAdd = [notifiedAddresses arrayByRemovingObjectsFromArray:preNotifiedAddresses];
    NSArray *addressesToRemove = [preNotifiedAddresses arrayByRemovingObjectsFromArray:notifiedAddresses];
    
    [self.provider refreshListItemContentsForObjects:lists];

    if ([addressesToAdd count] == 0 && [addressesToRemove count] == 0) {
        return;
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.provider removeAddresses:addressesToRemove];
        [self.provider addAddresses:addressesToAdd];
    });
}

#pragma mark - utility methods

- (NSArray *)notifiedAddressesForLists:(NSArray *)lists
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"notify = %@ AND ANY lists IN %@ AND SUBQUERY(lists, $list, $list.notify = %@).@count != 0", @YES, lists, @YES];
    [fetchRequest setPredicate:predicate];
    
    NSArray *notifiedAddresses = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        CCLog(@"%@", error);
        return @[];
    }
    
    return notifiedAddresses;
}

- (NSArray *)notifiedAddresses:(NSArray *)addresses
{
    NSPredicate *notifiedAddressesPredicate = [NSPredicate predicateWithFormat:@"notify = %@ AND SUBQUERY(lists, $list, $list.notify = %@).@count != 0", @YES, @YES];
    NSArray *notifiedAddresses = [addresses filteredArrayUsingPredicate:notifiedAddressesPredicate];
    return notifiedAddresses;
}

- (NSArray *)unnotifiedAddresses:(NSArray *)addresses
{
    NSPredicate *unnotifiedAddressesPredicate = [NSPredicate predicateWithFormat:@"notify = %@ AND SUBQUERY(lists, $list, $list.notify = %@).@count = 0", @NO, @YES];
    NSArray *unnotifiedAddresses = [addresses filteredArrayUsingPredicate:unnotifiedAddressesPredicate];
    return unnotifiedAddresses;
}

@end
