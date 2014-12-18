//
//  CCAddListViewController.m
//  Linotte
//
//  Created by stant on 17/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCAddListViewController.h"

#import "CCLinotteCoreDataStack.h"

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
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    
    CCList *list = [CCList insertInManagedObjectContext:managedObjectContext];
    list.name = name;
    [[CCLinotteCoreDataStack sharedInstance] saveContext];
    [[CCModelChangeMonitor sharedInstance] listsDidAdd:@[list] send:YES];
    
    @try {
        [[Mixpanel sharedInstance] track:@"List created" properties:@{@"name": list.name}];
    }
    @catch(NSException *e) {
        CCLog(@"%@", e);
    }
}

@end
