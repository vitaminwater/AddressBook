//
//  CCListSettingsViewController.m
//  Linotte
//
//  Created by stant on 19/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCAddressListSettingsViewController.h"

#import <RestKit/RestKit.h>

#import "CCAddressListSettingsView.h"

#import "CCList.h"
#import "CCAddress.h"

@interface CCAddressListSettingsViewController()

@property(nonatomic, strong)NSMutableArray *lists;

@property(nonatomic, strong)NSArray *list;
@property(nonatomic, strong)CCAddress *address;

@end

@implementation CCAddressListSettingsViewController

- (id)initWithAddress:(CCAddress *)address
{
    self = [super init];
    if (self) {
        _address = address;
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
    
    [self loadLists];
}

- (void)loadLists
{
    NSManagedObjectContext *managedObjectContext = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCList entityName]];
    
    NSArray *result = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    
    _lists = [result mutableCopy];
    [self sortLists];
}

- (void)sortLists
{
    NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [_lists sortUsingDescriptors:@[nameSortDescriptor]];
}

#pragma mark - CCListSettingsViewDelegate

/*- (void)closeListSettingsView:(id)sender success:(BOOL)success
{
    if (success) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
        
        UIImageView *completedImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"completed"]];
        hud.customView = completedImage;
        //hud.detailsLabelText = [NSString localizedStringByReplacingFromDictionnary:@{@"[listName]" : [_delegate addressName]} localizedKey:@"MOVED_TO"];
        
        hud.mode = MBProgressHUDModeCustomView;
        hud.opacity = 0.4;
        
        [hud show:YES];
        [hud hide:YES afterDelay:1];
    }
    [UIView animateWithDuration:0.2 animations:^{
        _listSettingsView.alpha = 0;
    } completion:^(BOOL finished) {
        [_listSettingsView removeFromSuperview];
        _listSettingsView = nil;
    }];
}*/

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
    NSManagedObjectContext *managedObjectContext = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    CCList *list = [CCList insertInManagedObjectContext:managedObjectContext];
    list.name = name;
    
    NSUInteger insertIndex = [_lists indexOfObject:list inSortedRange:(NSRange){0, [_lists count]} options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(CCList *obj1, CCList *obj2) {
        return [obj1.name compare:obj2.name];
    }];
    [_lists insertObject:list atIndex:insertIndex];
    [_address addListsObject:list];
    
    [managedObjectContext saveToPersistentStore:NULL];
    
    [_delegate listCreated:list];
    
    return insertIndex;
}

- (void)removeListAtIndex:(NSUInteger)index
{
    NSManagedObjectContext *context = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    
    CCList *list = _lists[index];
    [context deleteObject:list];
    [_lists removeObject:list];
    
    [context saveToPersistentStore:NULL];
}

- (void)listSelectedAtIndex:(NSUInteger)index
{
    CCList *list = _lists[index];
    [_address addListsObject:list];
    
    [[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext saveToPersistentStore:NULL];
    [_delegate address:_address movedToList:list];
}

- (void)listUnselectedAtIndex:(NSUInteger)index
{
    CCList *list = _lists[index];
    [_address removeListsObject:list];
    
    [[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext saveToPersistentStore:NULL];
    [_delegate address:_address movedFromList:list];
}

- (BOOL)isListSelectedAtIndex:(NSUInteger)index
{
    CCList *list = _lists[index];
    return [_address.lists containsObject:list];
}

@end
