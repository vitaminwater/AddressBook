//
//  CCLastNotificationModel.m
//  Linotte
//
//  Created by stant on 24/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCLastNotificationModel.h"

#import "CCLinotteCoreDataStack.h"
#import "CCDictStackCache.h"

#import "CCListViewContentProvider.h"

#import "CCAddress.h"
#import "CCList.h"

@implementation CCLastNotificationModel

@synthesize provider;

#pragma mark CCListViewModelProtocol methods

- (void)loadListItems
{
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    
    // Addresses
    {
        NSError *error = nil;
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
        
        NSPredicate *predicate;
        predicate = [NSPredicate predicateWithFormat:@"lastnotif != nil"];
        [fetchRequest setPredicate:predicate];
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastnotif" ascending:NO];
        [fetchRequest setSortDescriptors:@[sortDescriptor]];
        
        [fetchRequest setFetchLimit:50];
        
        NSArray *addresses = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if (error != nil)
            CCLog(@"%@", error);
        else
            [self.provider addAddresses:addresses];
    }
}

#pragma mark CCModelChangeMonitorDelegate methods

- (void)addresses:(NSArray *)addresses didMoveFromList:(CCList *)list send:(BOOL)send
{
    NSPredicate *toDeletePredicate = [NSPredicate predicateWithFormat:@"lists.@count = 0"];
    NSArray *toDeleteAddresses = [addresses filteredArrayUsingPredicate:toDeletePredicate];
    
    [self.provider removeAddresses:toDeleteAddresses];
}

- (void)addressesDidUpdate:(NSArray *)addresses send:(BOOL)send
{
    [self.provider refreshListItemContentsForObjects:addresses];
}

- (void)addressesDidUpdateUserData:(NSArray *)addresses send:(BOOL)send
{
    [self.provider refreshListItemContentsForObjects:addresses];
}

- (void)addresses:(NSArray *)addresses didMoveToList:(CCList *)list send:(BOOL)send
{
    [self.provider refreshListItemContentsForObjects:addresses];
}

- (void)addressesDidNotify:(NSArray *)addresses
{
    [self.provider addAddresses:addresses];
}

@end
