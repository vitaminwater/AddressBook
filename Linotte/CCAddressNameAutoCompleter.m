//
//  CCAutoCompleteAddressName.m
//  Linotte
//
//  Created by stant on 22/10/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCAddressNameAutoCompleter.h"

#import <AFNetworking/AFNetworking.h>

#import "CCGeohashHelper.h"

#import "CCLocationMonitor.h"

/**
 * Address storage class
 */

@implementation CCAddViewAutocompletionResultCategorie
@end

/***************/

@implementation CCAddViewAutocompletionResult
@end

/***************/

@implementation CCAddressNameAutoCompleter
{
    AFHTTPSessionManager *_manager;
    
    NSString *_clientSecret;
    NSString *_clientId;
    NSString *_version;
    
    CLLocation *_currentLocation;
    
    NSDictionary *_nextFoursquarePlaceQuery;
    BOOL _isLoadingFoursquarePlace;
    
    NSString *_currentGeohash;
    
    void (^_geolocBlock)();
    
    NSMutableArray *_autocompletionResults;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _autocompletionResults = [@[] mutableCopy];
        _manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.foursquare.com"]];
        _manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        _clientSecret = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"foursquare_client_secret"];
        _clientId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"foursquare_client_id"];
        _version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"foursquare_version"];
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
    
    if (_geolocBlock)
        _geolocBlock(location);
}

#pragma mark - management methods

- (void)autocompleteAddressName:(NSString *)addressName
{
    __weak typeof(self) weakSelf = self;
    if (_currentLocation)
        [self loadPlacesWebserviceByName:addressName];
    else
        [_delegate autocompeteWaitingLocation:self];
    _geolocBlock = ^() {
        [weakSelf loadPlacesWebserviceByName:addressName];
    };
    [[CCLocationMonitor sharedInstance] addDelegate:self];
}

- (void)stopAutoComplete
{
    [[CCLocationMonitor sharedInstance] removeDelegate:self];
    _nextFoursquarePlaceQuery = nil;
    _isLoadingFoursquarePlace = NO;
    _geolocBlock = nil;
}

#pragma mark - Foursquare methods

- (NSMutableDictionary *)defaultFoursquareArgs
{
    NSMutableDictionary *args = [@{@"client_id" : _clientId, @"client_secret" : _clientSecret, @"v" : _version, @"intent" : @"checkin"} mutableCopy];
    
    if (_currentLocation) {
        NSString *locationString = [NSString stringWithFormat:@"%f,%f", _currentLocation.coordinate.latitude, _currentLocation.coordinate.longitude];
        args[@"ll"] = locationString;
        args[@"radius"] = @"1000000000000";
    }
    
    return args;
}

- (void)loadPlacesWebserviceByName:(NSString *)name
{
    NSMutableDictionary *args = [self defaultFoursquareArgs];
    args[@"query"] = name;
    [self loadFoursquareVenueSearchWebservice:args];
}

- (void)loadFoursquareVenueSearchWebservice:(NSDictionary *)args
{
    if (_isLoadingFoursquarePlace) {
        _nextFoursquarePlaceQuery = args;
        return;
    }
    _isLoadingFoursquarePlace = YES;
    
    [_delegate autocompleteStarted:self];
    
    [_manager GET:@"/v2/venues/search/" parameters:args success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        // exclude categories
        NSArray *excludedCategories = @[@"50aa9e094b90af0d42d5de0d", @"5345731ebcbc57f1066c39b2", @"530e33ccbcbc57f1066bbff7", @"4f2a25ac4b909258e854f55f", @"530e33ccbcbc57f1066bbff8", @"530e33ccbcbc57f1066bbff3", @"530e33ccbcbc57f1066bbff9"];
        NSArray *venues = [response[@"response"][@"venues"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SUBQUERY(categories, $category, $category.identifier IN %@).@count = 0", excludedCategories]];
        
        [_autocompletionResults removeAllObjects];
        
        for (NSDictionary *venue in venues) {
            CCAddViewAutocompletionResult *autocompletionResult = [CCAddViewAutocompletionResult new];
            NSString *addressString = [venue[@"location"][@"formattedAddress"] componentsJoinedByString:@", "];
            
            NSMutableArray *categories = [@[] mutableCopy];
            for (NSDictionary *categorie in venue[@"categories"]) {
                CCAddViewAutocompletionResultCategorie *autocompletionCategorie = [CCAddViewAutocompletionResultCategorie new];
                autocompletionCategorie.identifier = categorie[@"id"];
                autocompletionCategorie.name = categorie[@"name"];
                [categories addObject:autocompletionCategorie];
            }
            
            autocompletionResult.name = venue[@"name"];
            autocompletionResult.address = addressString;
            autocompletionResult.categories = categories;
            autocompletionResult.provider = @"foursquare";
            autocompletionResult.providerId = venue[@"id"];
            autocompletionResult.coordinates = CLLocationCoordinate2DMake([venue[@"location"][@"lat"] doubleValue], [venue[@"location"][@"lng"] doubleValue]);
            [_autocompletionResults addObject:autocompletionResult];
            [_delegate autocompleteResultsRecieved:self];
        }
        [self foursquareRequestEnded];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self foursquareRequestEnded];
    }];
}

#pragma mark - data methods

- (NSUInteger)numberOfAutocompletionResults
{
    return [_autocompletionResults count];
}

- (CCAddViewAutocompletionResult *)autocompletionResultAtIndex:(NSUInteger)index
{
    return _autocompletionResults[index];
}

- (void)foursquareRequestEnded
{
    _isLoadingFoursquarePlace = NO;
    if (_nextFoursquarePlaceQuery != nil)
        [self loadFoursquareVenueSearchWebservice:_nextFoursquarePlaceQuery];
    else
        [_delegate autocompleteEnded:self];
    _nextFoursquarePlaceQuery = nil;
}

@end
