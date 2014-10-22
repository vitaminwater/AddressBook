//
//  CCFirstAddressDisplaySettingsViewController.m
//  Linotte
//
//  Created by stant on 19/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCFirstAddressDisplaySettingsViewController.h"

#import <Mixpanel/Mixpanel.h>

#import "CCCoreDataStack.h"

#import "CCFirstDisplaySettingsView.h"

#import "CCModelChangeMonitor.h"

#import "CCAddress.h"


@implementation CCFirstAddressDisplaySettingsViewController
{
    CCAddress *_address;
}

- (instancetype)initWithAddress:(CCAddress *)address
{
    self = [super init];
    if (self) {
        _address = address;
    }
    return self;
}

- (void)loadContentView
{
    CCFirstDisplaySettingsView *view = [CCFirstDisplaySettingsView new];
    view.delegate = self;
    self.contentView = view;
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    [super willMoveToParentViewController:parent];
}

#pragma mark - CCFirstAddressDisplaySettingsViewDelegate methods

- (void)setNotificationEnabled:(BOOL)enabled
{
    _address.notify = @(enabled);
    
    [[CCCoreDataStack sharedInstance] saveContext];
    [[CCModelChangeMonitor sharedInstance] addressDidUpdate:_address];
    [[Mixpanel sharedInstance] track:@"Notification enable" properties:@{@"name": _address.name, @"address": _address.address, @"identifier": _address.identifier, @"enabled": _address.notify}];
}

- (void)showListSetting
{
    [self.delegate showListSettings];
}

@end
