//
//  CCListSettingsViewController.m
//  Linotte
//
//  Created by stant on 19/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCAddressListSettingsViewController.h"

#import "CCCoreDataStack.h"

#import "CCAddressListSettingsView.h"

#import "CCModelChangeMonitor.h"

#import "CCList.h"
#import "CCAddress.h"


@implementation CCAddressListSettingsViewController
{
    NSMutableArray *_lists;
    
    CCAddress *_address;
}

- (instancetype)initWithAddress:(CCAddress *)address
{
    self = [super init];
    if (self) {
        _address = address;
        [self loadLists];
    }
    return self;
}

- (void)loadContentView
{
    CCAddressListSettingsView *view = [CCAddressListSettingsView new];
    view.delegate = self;
    self.contentView = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)loadLists
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCList entityName]];
    
    NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:@[nameSortDescriptor]];
    
    NSArray *result = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    
    _lists = [result mutableCopy];
}

#pragma mark - CCListSettingsViewDelegate

- (NSString *)addressName
{
    return _address.name;
}

- (NSUInteger)numberOfLists
{
    return [_lists count];
}

- (NSString *)listNameAtIndex:(NSUInteger)index
{
    CCList *list = _lists[index];
    return list.name;
}

- (NSString *)listIconAtIndex:(NSUInteger)index
{
    CCList *list = _lists[index];
    return list.icon;
}

- (NSUInteger)createListWithName:(NSString *)name
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    CCList *list = [CCList insertInManagedObjectContext:managedObjectContext];
    list.name = name;
    [[CCCoreDataStack sharedInstance] saveContext];
    [[CCModelChangeMonitor sharedInstance] listDidAdd:list];
    
    NSUInteger insertIndex = [_lists indexOfObject:list inSortedRange:(NSRange){0, [_lists count]} options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(CCList *obj1, CCList *obj2) {
        return [obj1.name compare:obj2.name];
    }];
    [_lists insertObject:list atIndex:insertIndex];
    
    [[CCModelChangeMonitor sharedInstance] address:_address willMoveToList:list];
    [_address addListsObject:list];
    [[CCCoreDataStack sharedInstance] saveContext];
    [[CCModelChangeMonitor sharedInstance] address:_address didMoveToList:list];
    
    return insertIndex;
}

- (void)removeListAtIndex:(NSUInteger)index
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    CCList *list = _lists[index];
    [[CCModelChangeMonitor sharedInstance] listWillRemove:list];
    [managedObjectContext deleteObject:list];
    [[CCCoreDataStack sharedInstance] saveContext];
    [[CCModelChangeMonitor sharedInstance] listDidRemove:list];

    [_lists removeObject:list];
}

- (void)listSelectedAtIndex:(NSUInteger)index
{
    CCList *list = _lists[index];
    [[CCModelChangeMonitor sharedInstance] address:_address willMoveToList:list];
    
    [_address addListsObject:list];
    
    [[CCCoreDataStack sharedInstance] saveContext];
    [[CCModelChangeMonitor sharedInstance] address:_address didMoveToList:list];
}

- (void)listUnselectedAtIndex:(NSUInteger)index
{
    CCList *list = _lists[index];
    [[CCModelChangeMonitor sharedInstance] address:_address willMoveFromList:list];
    
    [_address addListsObject:list];
    
    [[CCCoreDataStack sharedInstance] saveContext];
    [[CCModelChangeMonitor sharedInstance] address:_address didMoveFromList:list];
}

- (BOOL)isListSelectedAtIndex:(NSUInteger)index
{
    CCList *list = _lists[index];
    return [_address.lists containsObject:list];
}

@end
