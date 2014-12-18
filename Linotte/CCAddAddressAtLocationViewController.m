//
//  CCAddAddressAtLocationViewController.m
//  Linotte
//
//  Created by stant on 26/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCAddAddressAtLocationViewController.h"

#import <Mixpanel/Mixpanel.h>

#import "CCLocationMonitor.h"

#import "CCGeohashHelper.h"

#import "CCLinotteCoreDataStack.h"

#import "CCAddAddressAtLocationView.h"

#import "CCAddress.h"

@implementation CCAddAddressAtLocationViewController

@dynamic nameFieldValue;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"AT_LOCATION", @"");
        [[CCLocationMonitor sharedInstance] addDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [[CCLocationMonitor sharedInstance] removeDelegate:self];
}

- (void)loadView
{
    CCAddAddressAtLocationView *view = [CCAddAddressAtLocationView new];
    view.delegate = self;
    self.view = view;
}

- (void)setFirstInputAsFirstResponder
{
    [((CCAddAddressAtLocationView *)self.view) setFirstInputAsFirstResponder];
}

- (void)firstInputResignFirstResponder
{
    [((CCAddAddressAtLocationView *)self.view) cleanBeforeClose];
}

#pragma mark - getter/setter methods

- (NSString *)nameFieldValue
{
    CCAddAddressAtLocationView *view = (CCAddAddressAtLocationView *)self.view;
    return view.nameFieldValue;
}

- (void)setNameFieldValue:(NSString *)nameFieldValue
{
    CCAddAddressAtLocationView *view = (CCAddAddressAtLocationView *)self.view;
    view.nameFieldValue = nameFieldValue;
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    CCAddAddressAtLocationView *view = (CCAddAddressAtLocationView *)self.view;
    view.currentLocation = location.coordinate;
}

#pragma mark - CCAddAddressAtLocationViewDelegate methods

- (void)validateButtonPressed
{
    CCAddAddressAtLocationView *view = (CCAddAddressAtLocationView *)self.view;
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    CCAddress *address = [CCAddress insertInManagedObjectContext:managedObjectContext];
    
    CLLocationCoordinate2D addressCoordinates = view.addressCoordinates;
    address.name = view.nameFieldValue;
    address.address = [NSString stringWithFormat:@"%.05f %.05f", addressCoordinates.latitude, addressCoordinates.longitude];
    address.latitudeValue = addressCoordinates.latitude;
    address.longitudeValue = addressCoordinates.longitude;
    address.provider = @"";
    address.providerId = @"";
    address.isAuthorValue = YES;
    
    address.geohash = [CCGeohashHelper geohashFromCoordinates:addressCoordinates];
    
    [self.delegate addAddressViewController:self preSaveAddress:address];
    [[CCLinotteCoreDataStack sharedInstance] saveContext];
    [self.delegate addAddressViewController:self postSaveAddress:address];
    
    @try {
        [[Mixpanel sharedInstance] track:@"Address added" properties:@{@"name": address.name, @"address": address.address, @"provider": address.provider, @"providerId": address.providerId}];
    }
    @catch(NSException *e) {
        CCLog(@"%@", e);
    }
}

@end
