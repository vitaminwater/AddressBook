//
//  CCListListViewModel.m
//  Linotte
//
//  Created by stant on 13/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListListViewModel.h"

#import "CCCoreDataStack.h"
#import "CCDictStackCache.h"

#import "CCListViewContentProvider.h"

#import "CCList.h"
#import "CCAddress.h"

#define kCCListListViewModelDeletedAddressListsKey @"kCCListListViewModelDeletedAddressListsKey"
#define kCCListListViewModelDeletedListIndexKey @"kCCListListViewModelDeletedListIndexKey"

@implementation CCListListViewModel

@synthesize provider;

#pragma mark CCListViewModelProtocol methods

- (void)loadListItems
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCList entityName]];
    
    NSArray *lists = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    
    for (CCList *list in lists) {
        [self.provider addList:list];
    }
}

#pragma mark CCModelChangeMonitorDelegate methods

- (void)addressDidAdd:(CCAddress *)address fromNetwork:(BOOL)fromNetwork
{
    for (CCList *list in address.lists) {
        [self.provider addAddress:address toList:list];
    }
}

- (void)addressWillRemove:(CCAddress *)address fromNetwork:(BOOL)fromNetwork
{
    [self.cache pushCacheEntry:kCCListListViewModelDeletedAddressListsKey value:[address.lists allObjects]];
}

- (void)addressDidRemove:(NSString *)identifier fromNetwork:(BOOL)fromNetwork
{
    NSArray *lists = [self.cache popCacheEntry:kCCListListViewModelDeletedAddressListsKey];
    [self.provider refreshListItemContentsForObjects:lists];
}

- (void)listDidAdd:(CCList *)list fromNetwork:(BOOL)fromNetwork
{
    [self.provider addList:list];
}

- (void)listWillRemove:(CCList *)list fromNetwork:(BOOL)fromNetwork
{
    NSUInteger index = [self.provider indexOfListItemContent:list];
    [self.cache pushCacheEntry:kCCListListViewModelDeletedListIndexKey value:@(index)];
}

- (void)listDidRemove:(NSString *)identifier fromNetwork:(BOOL)fromNetwork
{
    NSUInteger index = [[self.cache popCacheEntry:kCCListListViewModelDeletedListIndexKey] unsignedIntegerValue];
    if (index == NSNotFound)
        return;
    [self.provider deleteItemAtIndex:index];
}

- (void)listDidUpdate:(CCList *)list fromNetwork:(BOOL)fromNetwork
{
    [self.provider refreshListItemContentForObject:list];
}

- (void)address:(CCAddress *)address didMoveToList:(CCList *)list fromNetwork:(BOOL)fromNetwork
{
    [self.provider addAddress:address toList:list];
}

- (void)address:(CCAddress *)address didMoveFromList:(CCList *)list fromNetwork:(BOOL)fromNetwork
{
    [self.provider removeAddress:address fromList:list];
}

@end
