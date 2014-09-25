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

- (void)expandList:(CCList *)list
{
    
}

- (void)reduceList:(CCList *)list
{
    
}

- (void)addAddress:(CCAddress *)address
{

}

- (void)removeAddress:(CCAddress *)address
{
    
}

- (void)updateAddress:(CCAddress *)address
{
    
}

- (void)addList:(CCList *)list
{
    
}

- (void)removeList:(CCList *)list
{
    
}

- (void)updateList:(CCList *)list
{
    
}

- (BOOL)address:(CCAddress *)address movedToList:(CCList *)list
{
    return NO;
}

- (BOOL)address:(CCAddress *)address movedFromList:(CCList *)list
{
    return NO;
}

@end
