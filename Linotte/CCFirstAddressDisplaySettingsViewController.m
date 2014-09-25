//
//  CCFirstAddressDisplaySettingsViewController.m
//  Linotte
//
//  Created by stant on 19/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCFirstAddressDisplaySettingsViewController.h"

#import <RestKit/RestKit.h>
#import <Mixpanel/Mixpanel.h>

#import "CCFirstDisplaySettingsView.h"

#import "CCModelChangeMonitor.h"

#import "CCAddress.h"

@interface CCFirstAddressDisplaySettingsViewController()

@property(nonatomic, strong)CCAddress *address;
@property(nonatomic, assign)BOOL notificationInitialValue;

@end

@implementation CCFirstAddressDisplaySettingsViewController

- (id)initWithAddress:(CCAddress *)address
{
    self = [super init];
    if (self) {
        _address = address;
        _notificationInitialValue = _address.notifyValue;
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
    if (parent == nil && _notificationInitialValue != _address.notifyValue) {
        [[[RKManagedObjectStore defaultStore] mainQueueManagedObjectContext] saveToPersistentStore:NULL];
        [[CCModelChangeMonitor sharedInstance] updateAddress:_address];
        [[Mixpanel sharedInstance] track:@"Notification enable" properties:@{@"name": _address.name, @"address": _address.address, @"identifier": _address.identifier, @"enabled": _address.notify}];
    }
}

#pragma mark - CCFirstAddressDisplaySettingsViewDelegate methods

- (void)setNotificationEnabled:(BOOL)enabled
{
    _address.notify = @(enabled);
}

- (void)showListSetting
{
    [self.delegate showListSettings];
}

@end
