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
    [[CCModelChangeMonitor sharedInstance] listDidAdd:list send:YES];
    
    NSUInteger insertIndex = [_lists indexOfObject:list inSortedRange:(NSRange){0, [_lists count]} options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(CCList *obj1, CCList *obj2) {
        return [obj1.name compare:obj2.name];
    }];
    [_lists insertObject:list atIndex:insertIndex];
    
    [[CCModelChangeMonitor sharedInstance] addresses:@[_address] willMoveToList:list send:YES];
    [_address addListsObject:list];
    [[CCCoreDataStack sharedInstance] saveContext];
    [[CCModelChangeMonitor sharedInstance] addresses:@[_address] didMoveToList:list send:YES];
    
    return insertIndex;
}

- (void)removeListAtIndex:(NSUInteger)index
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    CCList *list = _lists[index];
    NSString *identifier = list.identifier;
    [[CCModelChangeMonitor sharedInstance] listWillRemove:list send:YES];
    [managedObjectContext deleteObject:list];
    [[CCCoreDataStack sharedInstance] saveContext];
    [[CCModelChangeMonitor sharedInstance] listDidRemove:identifier send:YES];

    [_lists removeObject:list];
}

- (void)listSelectedAtIndex:(NSUInteger)index
{
    CCList *list = _lists[index];
    [[CCModelChangeMonitor sharedInstance] addresses:@[_address] willMoveToList:list send:YES];
    
    [_address addListsObject:list];
    
    [[CCCoreDataStack sharedInstance] saveContext];
    [[CCModelChangeMonitor sharedInstance] addresses:@[_address] didMoveToList:list send:YES];
}

- (void)listUnselectedAtIndex:(NSUInteger)index
{
    CCList *list = _lists[index];
    [[CCModelChangeMonitor sharedInstance] addresses:@[_address] willMoveFromList:list send:YES];
    
    [_address removeListsObject:list];
    
    [[CCCoreDataStack sharedInstance] saveContext];
    [[CCModelChangeMonitor sharedInstance] addresses:@[_address] didMoveFromList:list send:YES];
}

- (BOOL)isListSelectedAtIndex:(NSUInteger)index
{
    CCList *list = _lists[index];
    return [_address.lists containsObject:list];
}

@end
