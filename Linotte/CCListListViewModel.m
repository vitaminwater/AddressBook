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
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCList entityName]];
    
    NSArray *lists = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        CCLog(@"%@", error);
        return;
    }
    
    for (CCList *list in lists) {
        [self.provider addList:list];
    }
}

#pragma mark CCModelChangeMonitorDelegate methods

- (void)listDidAdd:(CCList *)list send:(BOOL)send
{
    [self.provider addList:list];
}

- (void)listWillRemove:(CCList *)list send:(BOOL)send
{
    NSUInteger index = [self.provider indexOfListItemContent:list];
    [self.cache pushCacheEntry:kCCListListViewModelDeletedListIndexKey value:@(index)];
}

- (void)listDidRemove:(NSString *)identifier send:(BOOL)send
{
    NSUInteger index = [[self.cache popCacheEntry:kCCListListViewModelDeletedListIndexKey] unsignedIntegerValue];
    if (index == NSNotFound)
        return;
    [self.provider deleteItemAtIndex:index];
}

- (void)listDidUpdate:(CCList *)list send:(BOOL)send
{
    [self.provider refreshListItemContentForObject:list];
}

- (void)addresses:(NSArray *)addresses didMoveToList:(CCList *)list send:(BOOL)send
{
    [self.provider addAddresses:addresses toList:list];
}

- (void)addresses:(NSArray *)addresses didMoveFromList:(CCList *)list send:(BOOL)send
{
    [self.provider removeAddresses:addresses fromList:list];
}

- (void)listDidUpdateUserData:(CCList *)list send:(BOOL)send
{
    [self.provider refreshListItemContentForObject:list];
}

@end
