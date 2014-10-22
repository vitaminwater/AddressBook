//
//  CCListOutputExpandedSettingsViewController.m
//  Linotte
//
//  Created by stant on 28/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListListExpandedSettingsViewController.h"

#import "CCCoreDataStack.h"

#import "CCListListExpandedSettingsView.h"

#import "CCModelChangeMonitor.h"

#import "CCList.h"

@implementation CCListListExpandedSettingsViewController
{
    NSArray *_lists;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self loadLists];
    }
    return self;
}

- (void)loadContentView
{
    CCListListExpandedSettingsView *view = [CCListListExpandedSettingsView new];
    view.delegate = self;
    self.contentView = view;
}

- (void)loadLists
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCList entityName]];
    
    NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:@[nameSortDescriptor]];
    
    _lists = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
}

#pragma mark CCListListExpandedSettingsViewDelegate methods

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

- (void)listSelectedAtIndex:(NSUInteger)index
{
    CCList *list = _lists[index];
    [[CCModelChangeMonitor sharedInstance] listWillExpand:list];
    list.expanded = @(YES);
    [[CCCoreDataStack sharedInstance] saveContext];
    [[CCModelChangeMonitor sharedInstance] listDidExpand:list];
}

- (void)listUnselectedAtIndex:(NSUInteger)index
{
    CCList *list = _lists[index];
    [[CCModelChangeMonitor sharedInstance] listWillReduce:list];
    list.expanded = @(NO);
    [[CCCoreDataStack sharedInstance] saveContext];
    [[CCModelChangeMonitor sharedInstance] listDidReduce:list];
}

- (BOOL)isListSelectedAtIndex:(NSUInteger)index
{
    CCList *list = _lists[index];
    return list.expandedValue;
}

@end
