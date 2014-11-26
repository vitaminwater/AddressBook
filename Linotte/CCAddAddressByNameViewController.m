//
//  CCAddViewController.m
//  Linotte
//
//  Created by stant on 06/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCAddAddressByNameViewController.h"

#import <Reachability/Reachability.h>

#import <MBProgressHUD/MBProgressHUD.h>

#import <Mixpanel/Mixpanel.h>

#import <geohash/geohash.h>

#import "CCAddressNameAutoCompleter.h"

#import "CCAddressNameAutoCompleter.h"
#import "CCAddressAutocompletionResult.h"
#import "CCAddressAutocompletionResultCategorie.h"

#import "CCCoreDataStack.h"

#import "CCModelChangeMonitor.h"

#import "CCGeohashHelper.h"
#import "CCNetworkHandler.h"

#import "CCAddAddressByNameView.h"

#import "CCAddress.h"
#import "CCCategory.h"
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
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    CCAddress *address = [CCAddress insertInManagedObjectContext:managedObjectContext];
    CCAddressAutocompletionResult *autocompletionResult = [self.autoComplete autocompletionResultAtIndex:index];
    
    address.name = autocompletionResult.name;
    address.address = autocompletionResult.address;
    address.provider = autocompletionResult.provider;
    address.providerId = autocompletionResult.providerId;
    address.date = [NSDate date];
    address.latitude = @(autocompletionResult.coordinates.latitude);
    address.longitude = @(autocompletionResult.coordinates.longitude);
    address.isAuthorValue = YES;
    
    address.geohash = [CCGeohashHelper geohashFromCoordinates:autocompletionResult.coordinates];
    
    for (CCAddressAutocompletionResultCategorie *categorie in autocompletionResult.categories) {
        CCCategory *categorieModel = [CCCategory insertInManagedObjectContext:managedObjectContext];
        categorieModel.identifier = categorie.identifier;
        categorieModel.name = categorie.name;
        [address addCategoriesObject:categorieModel];
    }
    
    [self.delegate addAddressViewController:self preSaveAddress:address];
    [[CCCoreDataStack sharedInstance] saveContext];
    [self.delegate addAddressViewController:self postSaveAddress:address];
    
    [self reduceAddView];
    @try {
        [[Mixpanel sharedInstance] track:@"Address added" properties:@{@"name": address.name, @"address": address.address, @"provider": address.provider, @"providerId": address.providerId}];
    }
    @catch(NSException *e) {
        CCLog(@"%@", e);
    }
}

@end
