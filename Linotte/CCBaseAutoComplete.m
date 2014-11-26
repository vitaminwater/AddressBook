//
//  CCBaseAutoComplete.m
//  Linotte
//
//  Created by stant on 24/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCBaseAutoComplete.h"

#import <AFNetworking/AFNetworking.h>

#import "CCAddressAutocompletionResult.h"
#import "CCAddressAutocompletionResultCategorie.h"

#import "CCGeohashHelper.h"

#import "CCLocationMonitor.h"

@implementation CCBaseAutoComplete
{
    BOOL _isLoading;
    
    NSString *_currentGeohash;
    
    NSMutableArray *_autocompletionResults;
    
    NSString *_nextText;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _autocompletionResults = [@[] mutableCopy];
    }
    return self;
}

- (void)dealloc
{
    [[CCLocationMonitor sharedInstance] removeDelegate:self];
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    _currentLocation = location;
    
    NSString *geohash = [CCGeohashHelper geohashFromCoordinates:_currentLocation.coordinate];
    
    if ([_currentGeohash isEqualToString:geohash])
        return;
    
    _currentGeohash = geohash;
    
    if (_nextText)
        [self loadSearchWebservice:_nextText];
}

#pragma mark - management methods

- (void)autocompleteText:(NSString *)text
{
    _nextText = text;
    if (_currentLocation) {
        [self loadSearchWebservice:_nextText];
    } else
        [_delegate autocompeteWaitingLocation:self];
    [[CCLocationMonitor sharedInstance] addDelegate:self];
}

- (void)stopAutoComplete
{
    [[CCLocationMonitor sharedInstance] removeDelegate:self];
    _nextText = nil;
    _isLoading = NO;
}

#pragma mark - Webservices methods

- (void)loadSearchWebservice:(NSString *)text
{
    if (_isLoading) {
        _nextText = text;
        return;
    }
    _isLoading = YES;
    
    [_delegate autocompleteStarted:self];
    
    [self callWebService:text];
}

- (void)callWebService:(NSString *)text {}

#pragma mark - data methods

- (void)clearResults
{
    _autocompletionResults = [@[] mutableCopy];
}

- (void)addResult:(CCAddressAutocompletionResult *)result
{
    [_autocompletionResults addObject:result];
}

- (NSUInteger)numberOfAutocompletionResults
{
    return [_autocompletionResults count];
}

- (CCAddressAutocompletionResult *)autocompletionResultAtIndex:(NSUInteger)index
{
    return _autocompletionResults[index];
}

- (void)requestEnded
{
    _isLoading = NO;
    if ([_autocompletionResults count])
        [_delegate autocompleteResultsRecieved:self];
    if (_nextText != nil)
        [self loadSearchWebservice:_nextText];
    else
        [_delegate autocompleteEnded:self];
    _nextText = nil;
}

@end
