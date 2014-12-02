//
//  CCAddAddressViewController.m
//  Linotte
//
//  Created by stant on 24/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCAutocompleteAddAddressViewController.h"

#import <Reachability/Reachability.h>

#import "CCBaseAutoComplete.h"
#import "CCAddressAutocompletionResult.h"

#import "CCAutocompleteAddAddressView.h"

@implementation CCAutocompleteAddAddressViewController
{
}

- (instancetype)initWithAutocompleter:(CCBaseAutoComplete *)autocomplete
{
    self = [super init];
    if (self) {
        _autoComplete = autocomplete;
        _autoComplete.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reachabilityChanged:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setFirstInputAsFirstResponder
{
    [((CCAutocompleteAddAddressView *)self.view) setFirstInputAsFirstResponder];
}

- (void)firstInputResignFirstResponder
{
    [((CCAutocompleteAddAddressView *)self.view) cleanBeforeClose];
}

#pragma mark - CCAddAddressViewDelegate methods

- (void)autocompletionResultSelectedAtIndex:(NSUInteger)index {}


- (void)autocompleteName:(NSString *)name
{
    [_autoComplete autocompleteText:name];
}

- (NSString *)nameForAutocompletionResultAtIndex:(NSUInteger)index
{
    CCAddressAutocompletionResult *autocompletionResult = [_autoComplete autocompletionResultAtIndex:index];
    return autocompletionResult.name;
}

- (NSString *)addressForAutocompletionResultAtIndex:(NSUInteger)index
{
    CCAddressAutocompletionResult *autocompletionResult = [_autoComplete autocompletionResultAtIndex:index];
    return autocompletionResult.address;
}

- (NSUInteger)numberOfAutocompletionResults
{
    return [_autoComplete numberOfAutocompletionResults];
}

#pragma mark - CCAddressNameAutocompletedDelegate methods

- (void)autocompeteWaitingLocation:(id)sender
{
    [(CCAutocompleteAddAddressView *)self.view showLoading:NSLocalizedString(@"AWAITING_LOCATION", @"")];
}

- (void)autocompleteStarted:(id)sender
{
    [(CCAutocompleteAddAddressView *)self.view showLoading:NSLocalizedString(@"LOADING", @"")];
}

- (void)autocompleteResultsRecieved:(id)sender
{
    [((CCAutocompleteAddAddressView *)self.view) reloadAutocompletionResults];
}

- (void)autocompleteEnded:(id)sender
{
    [(CCAutocompleteAddAddressView *)self.view hideLoading];
}

#pragma mark - NSNotificationCenter methods

- (void)reachabilityChanged:(NSNotification *)notification
{
    Reachability *reachability = notification.object;
    if (reachability.isReachable) {
        [((CCAutocompleteAddAddressView *)self.view) enableField];
    } else {
        [((CCAutocompleteAddAddressView *)self.view) disableField];
    }
}

#pragma mark - getter/setter methods

- (NSString *)nameFieldValue
{
    CCAutocompleteAddAddressView *view = (CCAutocompleteAddAddressView *)self.view;
    return view.nameFieldValue;
}

- (void)setNameFieldValue:(NSString *)nameFieldValue
{
    CCAutocompleteAddAddressView *view = (CCAutocompleteAddAddressView *)self.view;
    view.nameFieldValue = nameFieldValue;
}

@end
