//
//  CCHomeListViewModel.m
//  Linotte
//
//  Created by stant on 13/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCHomeListViewModel.h"

#import "CCCoreDataStack.h"

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
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lists.@count = 0 OR ANY lists.expanded = %@", @YES];
        [fetchRequest setPredicate:predicate];
        
        NSArray *addresses = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
        for (CCAddress *address in addresses) {
            [self.provider addAddress:address];
        }
    }
    
    // Lists
    {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCList entityName]];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"expanded = %@", @NO];
        [fetchRequest setPredicate:predicate];
        
        NSArray *lists = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
        for (CCList *list in lists) {
            [self.provider addList:list];
        }
    }
}

#pragma mark CCModelChangeMonitorDelegate methods

- (void)listDidExpand:(CCList *)list
{
    [self.provider removeList:list];
    
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY lists = %@ AND SUBQUERY(lists, $list, $list.expanded = %@).@count = 1", list, @YES];
    [fetchRequest setPredicate:predicate];
    
    NSArray *addresses = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    for (CCAddress *address in addresses) {
        [self.provider addAddress:address];
    }
}

- (void)listDidReduce:(CCList *)list
{
    [self.provider addList:list];
    
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY lists = %@ AND SUBQUERY(lists, $list, $list.expanded = %@).@count = 0", list, @YES];
    [fetchRequest setPredicate:predicate];
    
    NSArray *addresses = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    [self.provider removeAddresses:addresses];
}

- (void)addressDidAdd:(CCAddress *)address
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.expanded = %@", @NO];
    NSSet *match = [address.lists filteredSetUsingPredicate:predicate];
    
    if ([match count] == 0) {
        [self.provider addAddress:address];
    } else {
        for (CCList *list in match) {
            [self.provider addAddress:address toList:list];
        }
    }
}

- (void)addressWillRemove:(CCAddress *)address
{
    BOOL wasExpanded = [address.lists count] == 0;
    if (wasExpanded == NO) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.expanded = %@", @YES];
        NSSet *match = [address.lists filteredSetUsingPredicate:predicate];
        wasExpanded |= [match count] != 0;
    }
    
    if (wasExpanded)
        [self.provider removeAddress:address];
    
    [self pushCacheEntry:kCCHomeListViewModelDeletedAddressListsKey value:[address.lists allObjects]];
}

- (void)addressDidRemove:(CCAddress *)address
{
    NSArray *lists = [self popCacheEntry:kCCHomeListViewModelDeletedAddressListsKey];
    [self.provider refreshListItemContentsForObjects:lists];
}

- (void)addressDidUpdate:(CCAddress *)address
{
    BOOL  refreshListItem = [address.lists count] == 0;
    
    if (refreshListItem == NO){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.expanded = %@", @YES];
        NSSet *match = [address.lists filteredSetUsingPredicate:predicate];
    
        refreshListItem |= [match count] != 0;
    }
    if (refreshListItem) {
        [self.provider refreshListItemContentForObject:address];
    }
}

- (void)listDidAdd:(CCList *)list
{
    if (list.expandedValue == YES) {
        for (CCAddress *address in list.addresses) {
            [self.provider addAddress:address];
        }
    } else {
        [self.provider addList:list];
    }
}

- (void)listWillRemove:(CCList *)list
{
    if (list.expandedValue) {
        NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY lists = %@ AND SUBQUERY(ANY lists.expanded = %@).@count = 1", list, @YES];
        [fetchRequest setPredicate:predicate];
        
        NSArray *match = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
        [self.provider removeAddresses:match];
    } else {
        [self.provider removeList:list];
    }
}

- (void)listDidUpdate:(CCList *)list
{
    if (list.expandedValue == NO)
        [self.provider refreshListItemContentForObject:list];
}

- (void)address:(CCAddress *)address willMoveToList:(CCList *)list
{
    BOOL wasExpanded = [address.lists count] == 0;
    if (wasExpanded == NO) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.expanded = %@", @YES];
        NSSet *match = [address.lists filteredSetUsingPredicate:predicate];
        wasExpanded |= [match count] != 0;
    }
    
    if (list.expandedValue != wasExpanded) {
        if (list.expandedValue == YES) {
            [self.provider addAddress:address];
        } else {
            if ([address.lists count] == 0)
                [self.provider removeAddress:address];
        }
    }
    if (list.expandedValue == NO)
        [self.provider addAddress:address toList:list];
}

- (void)address:(CCAddress *)address willMoveFromList:(CCList *)list
{
    if (list.expandedValue == YES && [address.lists count] > 1) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.expanded = %@", @YES];
        NSSet *match = [address.lists filteredSetUsingPredicate:predicate];
        
        if ([match count] == 1) {
            [self.provider removeAddress:address];
        }
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.expanded = %@", @NO];
    NSSet *lists = [address.lists filteredSetUsingPredicate:predicate];
    
    [self pushCacheEntry:kCCHomeListViewModelAddressMovedFromListsKey value:lists.allObjects];
}

- (void)address:(CCAddress *)address didMoveFromList:(CCList *)list
{
    NSArray *lists = [self popCacheEntry:kCCHomeListViewModelAddressMovedFromListsKey];
    for (CCList *otherList in lists) {
        [self.provider removeAddress:address fromList:otherList];
    }
}

@end
