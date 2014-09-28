//
//  CCHomeListViewModel.m
//  Linotte
//
//  Created by stant on 13/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCHomeListViewModel.h"

#import <RestKit/RestKit.h>

#import "CCListViewContentProvider.h"

#import "CCAddress.h"
#import "CCList.h"

@implementation CCHomeListViewModel

@synthesize provider;

#pragma mark CCListViewModelProtocol methods

- (void)loadListItems
{
    NSManagedObjectContext *managedObjectContext = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    
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
    
    NSManagedObjectContext *managedObjectContext = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY lists = %@ AND SUBQUERY(ANY lists.expanded = %@).@count = 1", list, @YES];
    [fetchRequest setPredicate:predicate];
    
    NSArray *addresses = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    for (CCAddress *address in addresses) {
        [self.provider addAddress:address];
    }
}

- (void)listDidReduce:(CCList *)list
{
    [self.provider addList:list];
    
    NSManagedObjectContext *managedObjectContext = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY lists = %@ AND SUBQUERY(ANY lists.expanded = %@).@count = 0", list, @YES];
    [fetchRequest setPredicate:predicate];
    
    NSArray *addresses = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    [self.provider removeAddresses:addresses];
}

- (void)addressAdded:(CCAddress *)address
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

- (void)addressRemoved:(CCAddress *)address
{
    [self.provider removeAddress:address];
}

- (void)addressUpdated:(CCAddress *)address
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

- (void)listAdded:(CCList *)list
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
        NSManagedObjectContext *managedObjectContext = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY lists = %@ AND SUBQUERY(ANY lists.expanded = %@).@count = 1", list, @YES];
        [fetchRequest setPredicate:predicate];
        
        NSArray *match = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
        [self.provider removeAddresses:match];
    } else {
        [self.provider removeList:list];
    }
}

- (void)listUpdated:(CCList *)list
{
    if (list.expandedValue == NO)
        [self.provider refreshListItemContentForObject:list];
}

- (BOOL)address:(CCAddress *)address willMoveToList:(CCList *)list
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
        }
    }
    if (list.expandedValue == NO)
        [self.provider addAddress:address toList:list];
    return NO;
}

- (BOOL)address:(CCAddress *)address willMoveFromList:(CCList *)list
{
    if (list.expandedValue == YES && [address.lists count] > 1) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.expanded = %@", @YES];
        NSSet *match = [address.lists filteredSetUsingPredicate:predicate];
        
        if ([match count] == 1) {
            [self.provider removeAddress:address];
        }
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.expanded = %@", @NO];
    NSSet *match = [address.lists filteredSetUsingPredicate:predicate];
    for (CCList *otherList in match) {
        [self.provider removeAddress:address fromList:otherList];
    }
    return NO;
}

@end
