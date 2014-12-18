//
//  CCAddViewController.m
//  Linotte
//
//  Created by stant on 06/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCAddAddressByNameViewController.h"

#import <MBProgressHUD/MBProgressHUD.h>

#import <Mixpanel/Mixpanel.h>

#import <geohash/geohash.h>

#import "CCAddressNameAutoCompleter.h"

#import "CCAddressNameAutoCompleter.h"
#import "CCAddressAutocompletionResult.h"

#import "CCMeta.h"

#import "CCLinotteCoreDataStack.h"

#import "CCModelChangeMonitor.h"

#import "CCGeohashHelper.h"
#import "CCModelChangeHandler.h"

#import "CCAddAddressByNameView.h"

#import "CCAddress.h"
#import "CCAddressMeta.h"
#import "CCList.h"

/**
 * View controller implementation
 */

@implementation CCAddAddressByNameViewController

- (instancetype)init
{
    self = [super initWithAutocompleter:[CCAddressNameAutoCompleter new]];
    if (self) {
        self.title = NSLocalizedString(@"BY_NAME", @"");
    }
    return self;
}

- (void)loadView
{
    CCAddAddressByNameView *view = [CCAddAddressByNameView new];
    view.delegate = self;
    self.view = view;
}

#pragma mark - CCAddAddressViewDelegate methods

- (void)autocompletionResultSelectedAtIndex:(NSUInteger)index
{
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    CCAddress *address = [CCAddress insertInManagedObjectContext:managedObjectContext];
    CCAddressAutocompletionResult *autocompletionResult = [self.autoComplete autocompletionResultAtIndex:index];
    
    address.name = autocompletionResult.name;
    address.address = autocompletionResult.address;
    address.provider = autocompletionResult.provider;
    address.providerId = autocompletionResult.providerId;
    address.latitude = @(autocompletionResult.coordinates.latitude);
    address.longitude = @(autocompletionResult.coordinates.longitude);
    address.isAuthorValue = YES;
    
    address.geohash = [CCGeohashHelper geohashFromCoordinates:autocompletionResult.coordinates];
    
    for (CCMeta *meta in autocompletionResult.metas) {
        CCAddressMeta *addressMeta = [CCAddressMeta insertInManagedObjectContext:managedObjectContext];
        addressMeta.uid = meta.uid;
        addressMeta.action = meta.action;
        addressMeta.content = meta.content;
        [address addMetasObject:addressMeta];
    }
    
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
