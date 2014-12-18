//
//  CCFirstListDisplaySettingsViewController.m
//  Linotte
//
//  Created by stant on 19/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCFirstListDisplaySettingsViewController.h"

#import <Mixpanel/Mixpanel.h>

#import "CCLinotteCoreDataStack.h"
#import "CCModelChangeMonitor.h"

#import "CCFirstListDisplaySettingsView.h"

#import "CCList.h"

@interface CCFirstListDisplaySettingsViewController ()

@end

@implementation CCFirstListDisplaySettingsViewController
{
    CCList *_list;
}

- (instancetype)initWithList:(CCList *)list
{
    self = [super init];
    if (self) {
        _list = list;
    }
    return self;
}

- (void)loadContentView
{
    CCFirstListDisplaySettingsView *view = [CCFirstListDisplaySettingsView new];
    view.delegate = self;
    self.contentView = view;
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    [super willMoveToParentViewController:parent];
}

#pragma mark - CCFirstListDisplaySettingsViewDelegate methods

- (void)setNotificationEnabled:(BOOL)enabled
{
    [[CCModelChangeMonitor sharedInstance] listsWillUpdateUserData:@[_list] send:YES];
    _list.notify = @(enabled);
    
    [[CCLinotteCoreDataStack sharedInstance] saveContext];
    [[CCModelChangeMonitor sharedInstance] listsDidUpdateUserData:@[_list] send:YES];
    NSString *identifier = _list.identifier ?: @"NEW";
    @try {
        [[Mixpanel sharedInstance] track:@"Notification enable" properties:@{@"name": _list.name, @"identifier": identifier, @"enabled": _list.notify}];
    }
    @catch(NSException *e) {
        CCLog(@"%@", e);
    }
}

@end
