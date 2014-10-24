//
//  CCAddressSettingsViewController.m
//  Linotte
//
//  Created by stant on 19/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCAddressSettingsViewController.h"

#import "CCAddressSettingsView.h"

#import <Mixpanel/Mixpanel.h>
#import <MBProgressHUD/MBProgressHUD.h>

#import "CCCoreDataStack.h"

#import "CCModelChangeMonitor.h"

#import "CCAddress.h"


@implementation CCAddressSettingsViewController
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

- (void)dealloc
{
    
}

- (void)loadContentView
{
    CCAddressSettingsView *view = [CCAddressSettingsView new];
    view.delegate = self;
    view.notificationEnabled = [_address.notify boolValue];
    view.listNames = [self currentListNames];
    self.contentView = view;
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    [super willMoveToParentViewController:parent];
}

- (NSString *)currentListNames
{
    NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    NSArray *listArray = [[_address.lists allObjects] sortedArrayUsingDescriptors:@[nameSortDescriptor]];
    return [[listArray valueForKeyPath:@"@unionOfObjects.name"] componentsJoinedByString:@", "];
}

#pragma mark - CCAddressSettingsViewDelegate methods

- (void)setNotificationEnabled:(BOOL)enabled
{
    _address.notify = @(enabled);
    
    [[CCCoreDataStack sharedInstance] saveContext];
    [[CCModelChangeMonitor sharedInstance] addressDidUpdateUserData:_address];
    NSString *identifier = _address.identifier ?: @"NEW";
    [[Mixpanel sharedInstance] track:@"Notification enable" properties:@{@"name": _address.name, @"address": _address.address, @"identifier": identifier, @"enabled": _address.notify}];
}

- (void)showListSetting
{
    [self.delegate showListSettings];
}

@end
