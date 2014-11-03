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

#define kCCHomeListViewModelDeletedAddressListsKey @"kCCHomeListViewModelDeletedAddressListsKey"
#define kCCHomeListViewModelAddressMovedFromListsKey @"kCCHomeListViewModelAddressMovedFromListsKey"

@implementation CCHomeListViewModel

@synthesize provider;

#pragma mark CCListViewModelProtocol methods

- (void)loadListItems
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    // Addresses
    {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY lists.owned = %@", @YES];
        [fetchRequest setPredicate:predicate];
        
        NSArray *addresses = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
        for (CCAddress *address in addresses) {
            [self.provider addAddress:address];
        }
    }
    
    // Lists
    {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCList entityName]];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"owned = %@", @NO];
        [fetchRequest setPredicate:predicate];
        
        NSArray *lists = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
        for (CCList *list in lists) {
            [self.provider addList:list];
        }
    }
}

#pragma mark CCModelChangeMonitorDelegate methods

- (void)listDidExpand:(CCList *)list fromNetwork:(BOOL)fromNetwork
{
    [self.provider removeList:list];
    
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY lists = %@ AND SUBQUERY(lists, $list, $list.owned = %@).@count = 1", list, @YES];
    [fetchRequest setPredicate:predicate];
    
    NSArray *addresses = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    for (CCAddress *address in addresses) {
        [self.provider addAddress:address];
    }
}

- (void)listDidReduce:(CCList *)list fromNetwork:(BOOL)fromNetwork
{
    [self.provider addList:list];
    
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY lists = %@ AND SUBQUERY(lists, $list, $list.owned = %@).@count = 0", list, @YES];
    [fetchRequest setPredicate:predicate];
    
    NSArray *addresses = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    [self.provider removeAddresses:addresses];
}

- (void)addressDidAdd:(CCAddress *)address fromNetwork:(BOOL)fromNetwork
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.owned = %@", @NO];
    NSSet *match = [address.lists filteredSetUsingPredicate:predicate];
    
    if ([match count] == 0) {
        [self.provider addAddress:address];
    } else {
        for (CCList *list in match) {
            [self.provider addAddress:address toList:list];
        }
    }
}

- (void)addressWillRemove:(CCAddress *)address fromNetwork:(BOOL)fromNetwork
{
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.owned = %@", @YES];
        NSSet *match = [address.lists filteredSetUsingPredicate:predicate];
        
        if ([match count] > 0)
            [self.provider removeAddress:address];
    }
    
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.owned = %@", @NO];
        NSSet *match = [address.lists filteredSetUsingPredicate:predicate];
        
        [self.cache pushCacheEntry:kCCHomeListViewModelDeletedAddressListsKey value:[match allObjects]];
    }
}

- (void)addressDidRemove:(NSString *)identifier fromNetwork:(BOOL)fromNetwork
{
    NSArray *lists = [self.cache popCacheEntry:kCCHomeListViewModelDeletedAddressListsKey];
    
    if ([lists count])
        [self.provider refreshListItemContentsForObjects:lists];
}

- (void)addressDidUpdate:(CCAddress *)address fromNetwork:(BOOL)fromNetwork
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.owned = %@", @YES];
    NSSet *match = [address.lists filteredSetUsingPredicate:predicate];

    if ([match count] != 0) {
        [self.provider refreshListItemContentForObject:address];
    }
}

- (void)addressDidUpdateUserData:(CCAddress *)address fromNetwork:(BOOL)fromNetwork
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.owned = %@", @YES];
    NSSet *match = [address.lists filteredSetUsingPredicate:predicate];

    if ([match count] != 0) {
        [self.provider refreshListItemContentForObject:address];
    }
}

- (void)listDidAdd:(CCList *)list fromNetwork:(BOOL)fromNetwork
{
    if (list.ownedValue == YES) {
        for (CCAddress *address in list.addresses) {
            [self.provider addAddress:address];
        }
    } else {
        [self.provider addList:list];
    }
}

- (void)listWillRemove:(CCList *)list fromNetwork:(BOOL)fromNetwork
{
    if (list.ownedValue) {
        NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY lists = %@ AND SUBQUERY(lists, $list, $list.owned = %@).@count = 1", list, @YES];
        [fetchRequest setPredicate:predicate];
        
        NSArray *match = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
        [self.provider removeAddresses:match];
    } else {
        [self.provider removeList:list];
    }
}

- (void)listDidUpdate:(CCList *)list fromNetwork:(BOOL)fromNetwork
{
    if (list.ownedValue == NO)
        [self.provider refreshListItemContentForObject:list];
}

- (void)address:(CCAddress *)address willMoveToList:(CCList *)list fromNetwork:(BOOL)fromNetwork
{
    BOOL wasExpanded = [address.lists count] == 0;
    if (wasExpanded == NO) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.owned = %@", @YES];
        NSSet *match = [address.lists filteredSetUsingPredicate:predicate];
        wasExpanded |= [match count] != 0;
    }
    
    if (list.ownedValue != wasExpanded) {
        if (list.ownedValue == YES) {
            [self.provider addAddress:address];
        } else {
            if ([address.lists count] == 0)
                [self.provider removeAddress:address];
        }
    }
    if (list.ownedValue == NO)
        [self.provider addAddress:address toList:list];
}

- (void)address:(CCAddress *)address willMoveFromList:(CCList *)list fromNetwork:(BOOL)fromNetwork
{
    if (list.ownedValue == YES && [address.lists count] > 1) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.owned = %@", @YES];
        NSSet *match = [address.lists filteredSetUsingPredicate:predicate];
        
        if ([match count] == 1) {
            [self.provider removeAddress:address];
        }
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.owned = %@", @NO];
    NSSet *lists = [address.lists filteredSetUsingPredicate:predicate];
    
    [self.cache pushCacheEntry:kCCHomeListViewModelAddressMovedFromListsKey value:lists.allObjects];
}

- (void)address:(CCAddress *)address didMoveFromList:(CCList *)list fromNetwork:(BOOL)fromNetwork
{
    NSArray *lists = [self.cache popCacheEntry:kCCHomeListViewModelAddressMovedFromListsKey];
    for (CCList *otherList in lists) {
        [self.provider removeAddress:address fromList:otherList];
    }
}

@end
