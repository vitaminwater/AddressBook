//
//  CCListConfigViewController.m
//  Linotte
//
//  Created by stant on 09/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListConfigViewController.h"

#import <RestKit/RestKit.h>

#import <HexColors/HexColor.h>

#import "CCListConfigView.h"

#import "CCList.h"

@interface CCListConfigViewController ()

@property(nonatomic, assign)BOOL changedList;

@property(nonatomic, strong)NSMutableArray *lists;

@end

@implementation CCListConfigViewController

- (id)init
{
    self = [super init];
    if (self) {
        _changedList = NO;
    }
    return self;
}

- (void)loadView
{
    [self loadLists];

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    CCListConfigView *view = [CCListConfigView new];
    view.delegate = self;
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"LIST_CONFIG_CONTROLLER_TITLE", @"");
    
    NSString *color = @"#6b6b6b";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithHexString:color], NSFontAttributeName: [UIFont fontWithName:@"Montserrat-Bold" size:23]};
    
    { // left bar button items
        CGRect backButtonFrame = CGRectMake(0, 0, 30, 30);
        UIButton *backButton = [UIButton new];
        [backButton setImage:[UIImage imageNamed:@"back_icon.png"] forState:UIControlStateNormal];
        backButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        backButton.frame = backButtonFrame;
        [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        
        UIBarButtonItem *emptyBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        emptyBarButtonItem.width = -10;
        self.navigationItem.leftBarButtonItems = @[emptyBarButtonItem, barButtonItem];
    }
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    if (parent == nil && _changedList)
        [_delegate didChangedListConfig];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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

#pragma mark - UIBarButtons target methods

- (void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - CCListConfigViewDelegate methods

- (NSUInteger)createListWithName:(NSString *)name
{
    NSManagedObjectContext *managedObjectContext = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    CCList *list = [CCList insertInManagedObjectContext:managedObjectContext];
    list.name = name;
    
    NSUInteger insertIndex = [_lists indexOfObject:list inSortedRange:(NSRange){0, [_lists count]} options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(CCList *obj1, CCList *obj2) {
        return [obj1.name compare:obj2.name];
    }];
    [_lists insertObject:list atIndex:insertIndex];
    
    [managedObjectContext saveToPersistentStore:NULL];
    
    _changedList = YES;
    
    return insertIndex;
}

- (void)removeListAtIndex:(NSUInteger)index
{
    NSManagedObjectContext *context = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    
    CCList *list = _lists[index];
    [context deleteObject:list];
    [_lists removeObject:list];
    
    [context saveToPersistentStore:NULL];

    _changedList = YES;
}

- (void)listExpandedAtIndex:(NSUInteger)index
{
    CCList *list = _lists[index];
    list.expanded = @YES;
    
    [[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext saveToPersistentStore:NULL];

    _changedList = YES;
}

- (void)listUnexpandedAtIndex:(NSUInteger)index
{
    CCList *list = _lists[index];
    list.expanded = @NO;
    
    [[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext saveToPersistentStore:NULL];
    
    _changedList = YES;
}

- (BOOL)isListExpandedAtIndex:(NSUInteger)index
{
    CCList *list = _lists[index];
    return list.expandedValue;
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

@end
