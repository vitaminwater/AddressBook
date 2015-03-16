//
//  CCListListViewController.m
//  Linotte
//
//  Created by stant on 14/03/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import "CCListListViewController.h"

#import "CCLinotteCoreDataStack.h"

#import "CCListListView.h"

#import "CCList.h"

@implementation CCListListViewController
{
    NSMutableArray *_ownedLists;
    NSMutableArray *_otherLists;
    
    BOOL _loaded;
}

- (void)loadView
{
    _loaded = NO;
    CCListListView *view = [CCListListView new];
    view.delegate = self;
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadLists];
}

- (void)loadLists
{
    if (_loaded)
        return;
    
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCList entityName]];
    NSSortDescriptor *ownedSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"owned" ascending:NO];
    NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:@[ownedSortDescriptor, nameSortDescriptor]];
    
    NSArray *lists = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        CCLog(@"%@", error);
        return;
    }
    
    _ownedLists = [@[] mutableCopy];
    _otherLists = [@[] mutableCopy];
    for (CCList *list in lists) {
        if (list.ownedValue == YES) {
            [_ownedLists addObject:list];
        } else {
            [_otherLists addObject:list];
        }
    }
    
    [((CCListListView *)self.view) reloadListView];
    
    _loaded = YES;
}

#pragma mark - CCListListViewDelegate methods

- (NSUInteger)numberOfSections
{
    return 2;
}

- (NSUInteger)numberOfListsInSection:(NSUInteger)section
{
    if (section == 0)
        return [_ownedLists count];
    else
        return [_otherLists count];
}

- (NSString *)titleForSection:(NSUInteger)section
{
    if (section == 0)
        return NSLocalizedString(@"MY_BOOKS", @"");
    else
        return NSLocalizedString(@"MY_SUBSCRIPTION", @"");
}

- (NSString *)listNameAtIndex:(NSUInteger)index inSection:(NSUInteger)section
{
    CCList *list;
    if (section == 0)
        list = _ownedLists[index];
    else
        list = _otherLists[index];
    return list.name;
}

- (UIImage *)listIconAtIndex:(NSUInteger)index inSection:(NSUInteger)section
{
    CCList *list;
    if (section == 0)
        list = _ownedLists[index];
    else
        list = _otherLists[index];
    return nil;
}

- (NSUInteger)numberOfAddressAtIndex:(NSUInteger)index inSection:(NSUInteger)section
{
    CCList *list;
    if (section == 0)
        list = _ownedLists[index];
    else
        list = _otherLists[index];
    return [list numberOfAddresses];
}

- (NSString *)authorNameAtIndex:(NSUInteger)index inSection:(NSUInteger)section
{
    if (section == 0)
        return NSLocalizedString(@"ME", @"");
    CCList *list = _otherLists[index];
    return list.author;
}

@end
