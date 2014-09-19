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

#import "CCAddress.h"

@interface CCAddressSettingsViewController()

@property(nonatomic, strong)CCAddress *address;

@end

@implementation CCAddressSettingsViewController

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
    CCAddressSettingsView *view = [CCAddressSettingsView new];
    view.delegate = self;
    view.notificationEnabled = [_address.notify boolValue];
    view.listNames = [self currentListNames];
    self.contentView = view;
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
    [[[RKManagedObjectStore defaultStore] mainQueueManagedObjectContext] saveToPersistentStore:NULL];
    [_delegate addressNotificationChanged:_address];
    
    [[Mixpanel sharedInstance] track:@"Notification enable" properties:@{@"name": _address.name, @"address": _address.address, @"identifier": _address.identifier, @"enabled": @(enabled)}];
    
    /*BOOL locationEnabled = [CLLocationManager locationServicesEnabled];
    BOOL locationAuthorized = [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized;
    if (enable && (!locationEnabled || !locationAuthorized)) {
        NSString *alertTitle = NSLocalizedString(@"REQUEST_GEOLOC_ENABLED_TITLE", @"");
        NSString *alertMessage = NSLocalizedString(@"REQUEST_GEOLOC_ENABLED_MESSAGE", @"");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    }*/
}

- (void)showListSetting
{
    
}

@end
