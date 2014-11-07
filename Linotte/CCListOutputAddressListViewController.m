//
//  CCListOutputAddressListViewController.m
//  Linotte
//
//  Created by stant on 25/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListOutputAddressListViewController.h"

#import "CCCoreDataStack.h"

#import "CCListOutputAddressListView.h"

#import "CCModelChangeMonitor.h"

#import "CCList.h"
#import "CCAddress.h"

@implementation CCListOutputAddressListViewController
{
    CCList *_list;
    
    NSArray *_addresses;
}

- (instancetype)initWithList:(CCList *)list
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
    
    [self loadAddresses:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)loadAddresses:(NSString *)filterString
{
    _addresses = [@[] mutableCopy];
    
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
    
    if ([filterString length]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@ OR address CONTAINS[cd] %@", filterString, filterString];
        [fetchRequest setPredicate:predicate];
    }
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    [fetchRequest setFetchBatchSize:50];
    
    _addresses = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
}

#pragma mark CCListOutputAddressListViewDelegate methods

- (void)filterAddresses:(NSString *)filterString
{
    [self loadAddresses:filterString];
    [((CCListOutputAddressListView *)self.view) reloadList];
}

- (void)closePressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addressAddedAtIndex:(NSUInteger)index
{
    CCAddress *address = _addresses[index];
    
    [[CCModelChangeMonitor sharedInstance] addresses:@[address] willMoveToList:_list send:YES];
    [_list addAddressesObject:address];
    [[CCCoreDataStack sharedInstance] saveContext];
    [[CCModelChangeMonitor sharedInstance] addresses:@[address] didMoveToList:_list send:YES];
}

- (void)addressUnaddedAtIndex:(NSUInteger)index
{
    CCAddress *address = _addresses[index];
    
    [[CCModelChangeMonitor sharedInstance] addresses:@[address] willMoveFromList:_list send:YES];
    [_list removeAddressesObject:address];
    [[CCCoreDataStack sharedInstance] saveContext];
    [[CCModelChangeMonitor sharedInstance] addresses:@[address] didMoveFromList:_list send:YES];
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
