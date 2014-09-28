//
//  CCListOutputAddressListViewController.m
//  Linotte
//
//  Created by stant on 25/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListOutputAddressListViewController.h"

#import <RestKit/RestKit.h>

#import "CCListOutputAddressListView.h"

#import "CCModelChangeMonitor.h"

#import "CCList.h"
#import "CCAddress.h"

@implementation CCListOutputAddressListViewController
{
    CCList *_list;
    
    NSMutableArray *_addresses;
}

- (id)initWithList:(CCList *)list
{
    self = [super init];
    if (self) {
        _list = list;
    }
    return self;
}

- (void)loadView
{
    CCListOutputAddressListView *view = [CCListOutputAddressListView new];
    view.delegate = self;
    self.view = view;
    
    [self loadAddresses];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)loadAddresses
{
    _addresses = [@[] mutableCopy];
    
    NSManagedObjectContext *managedObjectContext = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSArray *addresses = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    [_addresses addObjectsFromArray:addresses];
}

#pragma mark CCListOutputAddressListViewDelegate methods

- (void)closePressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addressAddedAtIndex:(NSUInteger)index
{
    NSManagedObjectContext *managedObjectContext = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    CCAddress *address = _addresses[index];
    
    [[CCModelChangeMonitor sharedInstance] address:address willMoveToList:_list];
    [_list addAddressesObject:address];
    [[CCModelChangeMonitor sharedInstance] address:address didMoveToList:_list];
    [managedObjectContext saveToPersistentStore:NULL];
}

- (void)addressUnaddedAtIndex:(NSUInteger)index
{
    NSManagedObjectContext *managedObjectContext = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    CCAddress *address = _addresses[index];
    
    [[CCModelChangeMonitor sharedInstance] address:address willMoveFromList:_list];
    [_list removeAddressesObject:address];
    [[CCModelChangeMonitor sharedInstance] address:address didMoveFromList:_list];
    [managedObjectContext saveToPersistentStore:NULL];
}

- (BOOL)addressIsAddedAtIndex:(NSUInteger)index
{
    CCAddress *address = _addresses[index];
    
    return [_list.addresses containsObject:address];
}

- (NSString *)nameForAddressAtIndex:(NSUInteger)index
{
    CCAddress *address = _addresses[index];
    return address.name;
}

- (NSString *)addressForAddressAtIndex:(NSUInteger)index
{
    CCAddress *address = _addresses[index];
    return address.address;
}

- (NSUInteger)numberOfAddresses
{
    return [_addresses count];
}

@end
