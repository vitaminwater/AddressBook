//
//  CCAddViewController.m
//  Linotte
//
//  Created by stant on 06/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCAddViewController.h"

#import <RestKit/RestKit.h>

#import <Reachability/Reachability.h>

#import <MBProgressHUD/MBProgressHUD.h>

#import "CCFoursquareVenues.h"
#import "CCFoursquareCategorie.h"

#import "CCGeohashHelper.h"
#import "CCNetworkHandler.h"

#import "CCRestKit.h"

#import "CCAddView.h"

#import <geohash/geohash.h>

/**
 * Address storage class
 */

@interface CCAddViewAutocompletionResultCategorie : NSObject

@property(nonatomic, strong)NSString *identifier;
@property(nonatomic, strong)NSString *name;

@end

@implementation CCAddViewAutocompletionResultCategorie
@end

/***************/

@interface CCAddViewAutocompletionResult : NSObject

@property(nonatomic, strong)NSString *address;
@property(nonatomic, strong)NSString *name;

@property(nonatomic, strong)NSArray *categories;

@property(nonatomic, strong)NSString *reference;
@property(nonatomic, assign)CLLocationCoordinate2D coordinates;

@end

@implementation CCAddViewAutocompletionResult
@end

/**
 * View controller implementation
 */

@interface CCAddViewController ()
{
    CLLocationManager *_locationManager;
    CLLocation *_currentLocation;
    
    NSDictionary *_nextFoursquarePlaceQuery;
    BOOL _isLoadingFoursquarePlace;
    
    NSString *_currentGeohash;
    
    void (^geolocBlock)();
}

@property(nonatomic, strong)NSMutableArray *autocompletionResults;

@end

@implementation CCAddViewController

- (id)init
{
    self = [super init];
    if (self) {
        _autocompletionResults = [@[] mutableCopy];
    }
    return self;
}

- (void)loadView
{
    CCAddView *addView = [CCAddView new];
    addView.delegate = self;
    self.view = addView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    
    if (geolocBlock)
        geolocBlock(location);
}

#pragma mark - API management

- (void)autocompleteAddressName:(NSString *)addressName
{
    __weak id weakSelf = self;
    if (_currentLocation)
        [self loadPlacesWebserviceByName:addressName];
    geolocBlock = ^() {
        [weakSelf loadPlacesWebserviceByName:addressName];
    };
}

- (void)stopGeoloc
{
    [_locationManager stopUpdatingLocation];
    geolocBlock = nil;
}

- (void)startGeoloc
{
    if (_locationManager == nil) {
        _locationManager = [CLLocationManager new];
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.delegate = self;
    }
    [_locationManager startUpdatingLocation];
}

#pragma mark - Foursquare methods

- (NSMutableDictionary *)defaultFoursquareArgs
{
    NSString *clientSecret = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"foursquare_client_secret"];
    NSString *clientId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"foursquare_client_id"];
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"foursquare_version"];
    NSMutableDictionary *args = [@{@"client_id" : clientId, @"client_secret" : clientSecret, @"v" : version, @"intent" : @"checkin"} mutableCopy];
    
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
    
    [(CCAddView *)self.view showLoading];
    
    RKObjectManager *objectManager = [CCRestKit getObjectManager:kCCFoursquareObjectManager];
    [objectManager getObjectsAtPath:kCCFoursquareAPIVenueSearch parameters:args success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSArray *venues = mappingResult.array;
        
        [_autocompletionResults removeAllObjects];
        
        for (CCFoursquareVenues *result in venues) {
            CCAddViewAutocompletionResult *autocompletionResult = [CCAddViewAutocompletionResult new];
            autocompletionResult.name = result.name;
            NSString *addressString = @"";
            for (NSString *addr in @[result.address ? result.address : @"", result.city ? result.city : @"", result.country ? result.country : @""]) {
                if (addr.length) {
                    if (addressString.length)
                        addressString = [addressString stringByAppendingString:@", "];
                    addressString = [addressString stringByAppendingString:addr];
                }
            }
            
            NSMutableArray *categories = [@[] mutableCopy];
            for (CCFoursquareCategorie *categorie in result.categories) {
                CCAddViewAutocompletionResultCategorie *autocompletionCategorie = [CCAddViewAutocompletionResultCategorie new];
                autocompletionCategorie.identifier = categorie.identifier;
                autocompletionCategorie.name = categorie.name;
                [categories addObject:autocompletionCategorie];
            }
            
            autocompletionResult.address = addressString;
            autocompletionResult.categories = categories;
            autocompletionResult.coordinates = CLLocationCoordinate2DMake([result.latitude doubleValue], [result.longitude doubleValue]);
            [_autocompletionResults addObject:autocompletionResult];
        }
        [(CCAddView *)self.view reloadAutocompletionResults];
        [self endFoursquareRequest];
        
        [(CCAddView *)self.view hideLoading];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self endFoursquareRequest];
        
        [(CCAddView *)self.view hideLoading];
    }];
}

- (void)endFoursquareRequest
{
    _isLoadingFoursquarePlace = NO;
    if (_nextFoursquarePlaceQuery != nil)
        [self loadFoursquareVenueSearchWebservice:_nextFoursquarePlaceQuery];
    _nextFoursquarePlaceQuery = nil;
}

#pragma mark - NSNotificationCenter methods

- (void)reachabilityChanged:(NSNotification *)notification
{
    Reachability *reachability = notification.object;
    if (reachability.isReachable) {
        [((CCAddView *)self.view) enableField];
    } else {
        [((CCAddView *)self.view) disableField];
    }
}

#pragma mark - CCAddViewDelegate methods

- (void)reduceAddView
{
    [_delegate reduceAddView];
    [self stopGeoloc];
    
    [(CCAddView *)self.view hideLoading];
    
    _nextFoursquarePlaceQuery = nil;
    _isLoadingFoursquarePlace = NO;
}

- (void)autocompleteName:(NSString *)name
{
    [self autocompleteAddressName:name];
    [_delegate expandAddView];
    [self startGeoloc];
}

- (NSString *)nameForAutocompletionResultAtIndex:(NSUInteger)index
{
    CCAddViewAutocompletionResult *autocompletionResult = _autocompletionResults[index];
    return autocompletionResult.name;
}

- (NSString *)addressForAutocompletionResultAtIndex:(NSUInteger)index
{
    CCAddViewAutocompletionResult *autocompletionResult = _autocompletionResults[index];
    return autocompletionResult.address;
}

- (NSUInteger)numberOfAutocompletionResults
{
    return [_autocompletionResults count];
}

- (void)autocompletionResultSelectedAtIndex:(NSUInteger)index
{
    NSManagedObjectContext *managedObjectContext = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    CCAddress *address = [CCAddress insertInManagedObjectContext:managedObjectContext];
    CCAddViewAutocompletionResult *autocompletionResult = _autocompletionResults[index];
    
    address.name = autocompletionResult.name;
    address.address = autocompletionResult.address;
    address.date = [NSDate date];
    address.latitude = @(autocompletionResult.coordinates.latitude);
    address.longitude = @(autocompletionResult.coordinates.longitude);
    address.identifier = [[NSUUID UUID] UUIDString];
    
    address.geohash = [CCGeohashHelper geohashFromCoordinates:autocompletionResult.coordinates];
    
    for (CCAddViewAutocompletionResultCategorie *categorie in autocompletionResult.categories) {
        CCCategory *categorieModel = [CCCategory insertInManagedObjectContext:managedObjectContext];
        categorieModel.identifier = categorie.identifier;
        categorieModel.name = categorie.name;
        [address addCategoriesObject:categorieModel];
    }
    
    [managedObjectContext saveToPersistentStore:NULL];
    [self reduceAddView];
    [_delegate addressAdded:address];
    [[CCNetworkHandler sharedInstance] sendAddress:address];
}

@end
