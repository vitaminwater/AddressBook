//
//  CCAddAddressByAddressViewController.m
//  Linotte
//
//  Created by stant on 25/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCAddAddressByAddressViewController.h"

#import <Mixpanel/Mixpanel.h>

#import "CCGeohashHelper.h"
#import "CCLinotteCoreDataStack.h"

#import "CCAddAddressByAddressView.h"

#import "CCStreetAddressAutoComplete.h"
#import "CCAddressAutocompletionResult.h"

#import "CCAddress.h"

@implementation CCAddAddressByAddressViewController

- (instancetype)init
{
    self = [super initWithAutocompleter:[CCStreetAddressAutoComplete new]];
    if (self) {
        self.title = NSLocalizedString(@"BY_ADDRESS", @"");
    }
    return self;
}

- (void)loadView
{
    CCAddAddressByAddressView *view = [CCAddAddressByAddressView new];
    view.delegate = self;
    self.view = view;
}

#pragma mark - CCAddAddressViewDelegate methods

- (void)autocompletionResultSelectedAtIndex:(NSUInteger)index
{
    NSString *addressName = ((CCAddAddressByAddressView *)self.view).nameFieldValue;
    CCStreetAddressAutoComplete *autoComplete = (CCStreetAddressAutoComplete *)self.autoComplete;
    
    [autoComplete fetchCompleteInfosForResultAtIndex:index completionBlock:^(CCAddressAutocompletionResult *result) {
        if (result == nil)
            return;
        
        NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
        CCAddress *address = [CCAddress insertInManagedObjectContext:managedObjectContext];

        address.name = addressName;
        address.address = result.address;
        address.provider = result.provider;
        address.providerId = result.providerId;
        address.latitude = @(result.coordinates.latitude);
        address.longitude = @(result.coordinates.longitude);
        address.isAuthorValue = YES;
        
        address.geohash = [CCGeohashHelper geohashFromCoordinates:result.coordinates];
        
        [self.delegate addAddressViewController:self preSaveAddress:address];
        [[CCLinotteCoreDataStack sharedInstance] saveContext];
        [self.delegate addAddressViewController:self postSaveAddress:address];

        @try {
            [[Mixpanel sharedInstance] track:@"Address added" properties:@{@"name": address.name, @"address": address.address, @"provider": address.provider, @"providerId": address.providerId}];
        }
        @catch(NSException *e) {
            CCLog(@"%@", e);
        }
    }];
}

@end
