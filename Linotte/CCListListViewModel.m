//
//  CCListListViewModel.m
//  Linotte
//
//  Created by stant on 13/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListListViewModel.h"

#import "CCLinotteCoreDataStack.h"
#import "CCDictStackCache.h"

#import "CCListViewContentProvider.h"

#import "CCList.h"
#import "CCAddress.h"

#define kCCListListViewModelDeletedAddressListsKey @"kCCListListViewModelDeletedAddressListsKey"
#define kCCListListViewModelDeletedListIndexKey @"kCCListListViewModelDeletedListIndexKey"

@implementation CCListListViewModel

@synthesize provider;

#pragma mark CCListViewModelProtocol methods

- (void)loadListItems:(NSString *)filterText
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCList entityName]];
    
    if (filterText != nil) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[c] %@", filterText];
        [fetchRequest setPredicate:predicate];
    }
    
    NSArray *lists = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        CCLog(@"%@", error);
        return;
    }
    
    [self.provider addLists:lists];
}

#pragma mark CCModelChangeMonitorDelegate methods

- (void)listsDidAdd:(NSArray *)lists send:(BOOL)send
{
    [self.provider addLists:lists];
}

- (void)listsWillRemove:(NSArray *)lists send:(BOOL)send
{
    NSIndexSet *indexes = [self.provider indexesOfListItemContents:lists handler:^(CCListItem *listItem) {}];
    [self.cache pushCacheEntry:kCCListListViewModelDeletedListIndexKey value:indexes];
}

- (void)listsDidRemove:(NSArray *)identifiers send:(BOOL)send
{
    NSIndexSet *indexes = [self.cache popCacheEntry:kCCListListViewModelDeletedListIndexKey];
    [self.provider deleteItemsAtIndexes:indexes];
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

- (void)listsDidUpdateUserData:(NSArray *)lists send:(BOOL)send
{
    [self.provider refreshListItemContentsForObjects:lists];
}

@end
