//
//  CCAddListViewController.m
//  Linotte
//
//  Created by stant on 17/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCAddListViewController.h"

#import "CCCoreDataStack.h"

#import <Mixpanel/Mixpanel.h>

#import "CCModelChangeMonitor.h"

#import "CCAddListView.h"

#import "CCList.h"

@implementation CCAddListViewController

- (void)loadView
{
    CCAddListView *view = [CCAddListView new];
    view.delegate = self;
    self.view = view;
}

#pragma mark - CCaddListViewDelegate methods

- (void)createListWithName:(NSString *)name
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    CCList *list = [CCList insertInManagedObjectContext:managedObjectContext];
    list.name = name;
    [[CCCoreDataStack sharedInstance] saveContext];
    [[CCModelChangeMonitor sharedInstance] listDidAdd:list];
    
    [[Mixpanel sharedInstance] track:@"List created" properties:@{@"name": list.name}];
}

@end
