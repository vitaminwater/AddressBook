//
//  CCAddressSettingsViewController.m
//  Linotte
//
//  Created by stant on 19/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCAddressSettingsViewController.h"

#import "CCAddressSettingsView.h"

#import <RestKit/RestKit.h>
#import <Mixpanel/Mixpanel.h>
#import <MBProgressHUD/MBProgressHUD.h>

#import "CCModelChangeMonitor.h"

#import "CCAddress.h"

@interface CCAddressSettingsViewController()

@property(nonatomic, strong)CCAddress *address;
@property(nonatomic, assign)BOOL notificationInitialValue;

@end

@implementation CCAddressSettingsViewController

- (id)initWithAddress:(CCAddress *)address
{
    self = [super init];
    if (self) {
        _address = address;
        _notificationInitialValue = _address.notifyValue;
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
    if (parent == nil && _notificationInitialValue != _address.notifyValue) {
        [[[RKManagedObjectStore defaultStore] mainQueueManagedObjectContext] saveToPersistentStore:NULL];
        [[CCModelChangeMonitor sharedInstance] updateAddress:_address];
        [[Mixpanel sharedInstance] track:@"Notification enable" properties:@{@"name": _address.name, @"address": _address.address, @"identifier": _address.identifier, @"enabled": _address.notify}];
    }
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
}

- (void)showListSetting
{
    [self.delegate showListSettings];
}

@end
