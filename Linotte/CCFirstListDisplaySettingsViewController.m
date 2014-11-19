//
//  CCFirstListDisplaySettingsViewController.m
//  Linotte
//
//  Created by stant on 19/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCFirstListDisplaySettingsViewController.h"

#import <Mixpanel/Mixpanel.h>

#import "CCCoreDataStack.h"
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
    _list.notify = @(enabled);
    
    [[CCCoreDataStack sharedInstance] saveContext];
    [[CCModelChangeMonitor sharedInstance] listDidUpdateUserData:_list send:YES];
    NSString *identifier = _list.identifier ?: @"NEW";
    [[Mixpanel sharedInstance] track:@"Notification enable" properties:@{@"name": _list.name, @"identifier": identifier, @"enabled": _list.notify}];
}

@end
