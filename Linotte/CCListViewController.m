//
//  CCListViewController.m
//  Linotte
//
//  Created by stant on 06/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListViewController.h"

#import <objc/runtime.h>

#import <Mixpanel/Mixpanel.h>

#import "CCGeohashHelper.h"

#import "NSString+CCLocalizedString.h"

#import "CCListConfigViewController.h"
#import "CCListStoreViewController.h"

#import "CCRestKit.h"

#import "CCListView.h"

#import "CCAddress.h"
#import "CCList.h"


#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiandsToDegrees(x) (x * 180.0 / M_PI)

/* http://stackoverflow.com/questions/3809337/calculating-bearing-between-two-cllocationcoordinate2ds */

float getHeadingForDirectionFromCoordinate(CLLocationCoordinate2D fromLoc, CLLocationCoordinate2D toLoc)
{
    float fLat = degreesToRadians(fromLoc.latitude);
    float fLng = degreesToRadians(fromLoc.longitude);
    float tLat = degreesToRadians(toLoc.latitude);
    float tLng = degreesToRadians(toLoc.longitude);
    
    float degree = radiandsToDegrees(atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng)));
    
    if (degree >= 0) {
        return degree;
    } else {
        return 360+degree;
    }
}

/*
 * Data model classes
 */

@interface CCListItem : NSObject

@property(nonatomic, strong)NSString *name;
@property(nonatomic, strong)CLLocation *location;
@property(nonatomic, strong)CLLocation *currentLocation;
@property(nonatomic, assign)BOOL farAway;

- (double)distanceFromLocation:(CLLocation *)currentLocation;
- (double)angleFromLocation:(CLLocation *)currentLocation heading:(CLHeading *)currentHeading;

- (void)handleOnSelect:(id<CCListViewControllerDelegate>)delegate;

@end

@implementation CCListItem

- (double)distanceFromLocation:(CLLocation *)currentLocation
{
    if (_farAway)
        return 10000; // TODO find right distance based on geohash
    return [currentLocation distanceFromLocation:_location];
}

- (double)angleFromLocation:(CLLocation *)currentLocation heading:(CLHeading *)currentHeading
{
    float angle = getHeadingForDirectionFromCoordinate(currentLocation.coordinate, _location.coordinate);
    return angle - currentHeading.magneticHeading;
}

- (void)handleOnSelect:(id<CCListViewControllerDelegate>)delegate {}

- (void)handleOnDelete {}

- (NSArray *)geohashLimit
{
    NSUInteger digits = 16;
    NSArray *geohashes = [CCGeohashHelper geohashGridSurroundingCoordinate:self.currentLocation.coordinate radius:1 digits:digits all:YES];
    NSMutableArray *geohashesComp = [@[] mutableCopy];
    for (NSString *geohash in geohashes) {
        NSString *subGeohash = [geohash substringToIndex:digits];
        [geohashesComp addObject:subGeohash];
    }
    return geohashesComp;
}

@end

/*
 * Address list item
 */
@interface CCListItemAddress : CCListItem

@property(nonatomic, strong)CCAddress *address;

@end

@implementation CCListItemAddress

- (void)setAddress:(CCAddress *)address
{
    _address = address;
    self.name = _address.name;
    self.location = [[CLLocation alloc] initWithLatitude:_address.latitudeValue longitude:_address.longitudeValue];
}

- (void)handleOnSelect:(id<CCListViewControllerDelegate>)delegate
{
    [delegate addressSelected:_address];
}

- (void)handleOnDelete
{
    NSError *error;
    NSManagedObjectContext *managedObjectContext = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    [[Mixpanel sharedInstance] track:@"Address deleted" properties:@{@"name": _address.name ?: @"",
                                                                     @"address": _address.address ?: @"",
                                                                     @"identifier": _address.identifier ?: @""}];
    
    [managedObjectContext deleteObject:_address];
    if ([managedObjectContext saveToPersistentStore:&error] == NO) {
        NSLog(@"%@", error);
        return;
    }
}

@end

/*
 * List list item
 */
@interface CCListItemList : CCListItem

@property(nonatomic, strong)CCList *list;

@end

@implementation CCListItemList

- (void)setList:(CCList *)list
{
    _list = list;
    self.name = [NSString stringWithFormat:@"Liste: %@", _list.name];
}

- (void)setCurrentLocation:(CLLocation *)currentLocation
{
    [super setCurrentLocation:currentLocation];
    
    if (self.currentLocation == nil)
        return;
    
    NSManagedObjectContext *managedObjectContext = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    
    NSArray *geohashesComp = [self geohashLimit];
    
    for (NSString *geohash in geohashesComp) {
        NSLog(@"%@", geohash);
    }

    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(ANY lists = %@) AND (geohash BEGINSWITH %@ OR geohash BEGINSWITH %@ OR geohash BEGINSWITH %@ OR geohash BEGINSWITH %@ OR geohash BEGINSWITH %@ OR geohash BEGINSWITH %@ OR geohash BEGINSWITH %@ OR geohash BEGINSWITH %@ OR geohash BEGINSWITH %@)", _list, geohashesComp[0], geohashesComp[1], geohashesComp[2], geohashesComp[3], geohashesComp[4], geohashesComp[5], geohashesComp[6], geohashesComp[7], geohashesComp[8]]; // TODO store pre calculated small geohash in model !
    [fetchRequest setPredicate:predicate];
    
    NSArray *addresses = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    
    if ([addresses count] == 0) {
        self.farAway = YES;
        return;
    }
    self.farAway = NO;
    
    CLLocation *closestLocation = nil;
    double distance = 42424242;
    for (CCAddress *address in addresses) {
        CLLocation *addressLocation = [[CLLocation alloc] initWithLatitude:address.latitudeValue longitude:address.longitudeValue];
        double newDistance = [self.currentLocation distanceFromLocation:addressLocation];
        if (newDistance < distance || closestLocation == nil)
            closestLocation = addressLocation;
    }
    self.location = closestLocation;
}

- (void)handleOnSelect:(id<CCListViewControllerDelegate>)delegate
{
    [delegate listSelected:_list];
}

@end

/*
 * Actual View controller implementation
 */

@interface CCListViewController ()
{
    CLLocationManager *_locationManager;
    CLLocation *_currentLocation;
    CLHeading *_currentHeading;
}

@property(nonatomic, strong)NSMutableArray *listItems;

@end

@implementation CCListViewController

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView
{
    [self loadListItems];
    CCListView *listView = [[CCListView alloc] initWithHelpOn:[_listItems count] == 0];
    listView.delegate = self;
    self.view = listView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_locationManager == nil) {
        _locationManager = [CLLocationManager new];
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.delegate = self;
    }
    [_locationManager startUpdatingLocation];
    [_locationManager startUpdatingHeading];
    
    CCListView *listView = (CCListView *)self.view;
    [listView unselect];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_locationManager stopUpdatingLocation];
    [_locationManager stopUpdatingHeading];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)loadListItems
{
    NSManagedObjectContext *managedObjectContext = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    
    _listItems = [@[] mutableCopy];
    // Addresses
    {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lists.@count = 0 OR ANY lists.expanded = %@", @YES];
        [fetchRequest setPredicate:predicate];
        
        NSArray *addresses = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
        for (CCAddress *address in addresses) {
            CCListItemAddress *itemAddress = [CCListItemAddress new];
            itemAddress.address = address;
            itemAddress.currentLocation = _currentLocation;
            [_listItems addObject:itemAddress];
        }
    }
    
    // Lists
    {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCList entityName]];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"expanded = %@", @NO];
        [fetchRequest setPredicate:predicate];
        
        NSArray *lists = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
        for (CCList *list in lists) {
            CCListItemList *itemList = [CCListItemList new];
            itemList.list = list;
            itemList.currentLocation = _currentLocation;
            [_listItems addObject:itemList];
        }
    }
    
    [_listItems sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [self nameSortMethod:obj1 obj2:obj2];
    }];
}

#pragma mark - sort methods

- (NSComparisonResult)nameSortMethod:(CCListItem *)obj1 obj2:(CCListItem *)obj2
{
    return [obj1.name compare:obj2.name options:NSCaseInsensitiveSearch];
}

- (NSComparisonResult)distanceSortMethod:(CCListItem *)obj1 obj2:(CCListItem *)obj2
{
    double distance1 = [obj1 distanceFromLocation:_currentLocation];
    double distance2 = [obj2 distanceFromLocation:_currentLocation];
    
    return [@(distance1) compare:@(distance2)];
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    
    if (_currentLocation != nil && [_currentLocation distanceFromLocation:location] < 10) {
        return;
    }
    
    _currentLocation = location;
    
    __weak CCListViewController *weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        for (CCListItem *listItem in _listItems) {
            listItem.currentLocation = _currentLocation;
        }
        
        [_listItems sortUsingComparator:^NSComparisonResult(CCListItem *obj1, CCListItem *obj2) {
            return [weakSelf distanceSortMethod:obj1 obj2:obj2];
        }];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [((CCListView *)weakSelf.view) reloadVisibleListItems];
        });
    });
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    _currentHeading = newHeading;
    [((CCListView *)self.view) reloadVisibleListItems];
}

#pragma mark - public methods

- (void)addressAdded:(CCAddress *)address
{
    NSUInteger newIndex;
    
    CCListItemAddress *listItemAddress = [CCListItemAddress new];
    listItemAddress.currentLocation = _currentLocation;
    listItemAddress.address = address;
    if (!_currentLocation) {
        newIndex = [_listItems indexOfObject:listItemAddress
                    inSortedRange:(NSRange){0, [_listItems count]}
                          options:NSBinarySearchingInsertionIndex
                  usingComparator:^NSComparisonResult(CCListItem *obj1, CCListItem *obj2) {
                      return [self nameSortMethod:obj1 obj2:obj2];
                  }];
    } else {
        newIndex = [_listItems indexOfObject:listItemAddress
                               inSortedRange:(NSRange){0, [_listItems count]}
                                     options:NSBinarySearchingInsertionIndex
                             usingComparator:^NSComparisonResult(CCListItem *obj1, CCListItem *obj2) {
                                 if (obj1.farAway == NO && obj2.farAway == NO)
                                     return [self distanceSortMethod:obj1 obj2:obj2];
                                 else if (obj1.farAway == YES && obj2.farAway == YES)
                                     return [self nameSortMethod:obj1 obj2:obj2];
                                 else if (obj1.farAway == NO && obj2.farAway == YES)
                                     return NSOrderedDescending;
                                 else
                                     return NSOrderedAscending;
                             }];
    }
    
    [_listItems insertObject:listItemAddress atIndex:newIndex];
    
    [((CCListView *)self.view) insertListItemAtIndex:newIndex];
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
        return;
    
    NSNumber *index = objc_getAssociatedObject(alertView, @"index");
    
    CCListItem *listItem = _listItems[[index intValue]];
    [_listItems removeObject:listItem];
    
    [listItem handleOnDelete];
    
    [((CCListView *)self.view) deleteListItemAtIndex:[index intValue]];
}

#pragma mark - CCListViewDelegate methods

- (void)didSelectListItemAtIndex:(NSUInteger)index color:(NSString *)color
{
    CCListItem *listItem = _listItems[index];
    [listItem handleOnSelect:_delegate];
}

- (void)deleteListItemAtIndex:(NSUInteger)index
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NOTIF_ADDELETE", @"") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"NOTIF_ADDELETE_N", @"") otherButtonTitles:NSLocalizedString(@"NOTIF_ADDELETE_Y", @""), nil];
    [alertView show];
    
    objc_setAssociatedObject(alertView, @"index", @(index), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (double)distanceForListItemAtIndex:(NSUInteger)index
{
    if (_currentLocation) {
        CCListItem *listItem = _listItems[index];
        return [listItem distanceFromLocation:_currentLocation];
    }
    return -1;
}

- (double)angleForListItemAtIndex:(NSUInteger)index
{
    if (_currentLocation) {
        CCListItem *listItem = _listItems[index];
        return [listItem angleFromLocation:_currentLocation heading:_currentHeading];
    }
    return 0;
}

- (NSString *)nameForListItemAtIndex:(NSUInteger)index
{
    CCListItem *listItem = _listItems[index];
    return listItem.name;
}

- (NSUInteger)numberOfListItems
{
    return [_listItems count];
}

- (void)showListManagement
{
    CCListConfigViewController *listConfigViewController = [CCListConfigViewController new];
    listConfigViewController.delegate = self;
    [self.navigationController pushViewController:listConfigViewController animated:YES];
}

- (void)showListStore
{
    CCListStoreViewController *listStoreViewController = [CCListStoreViewController new];
    [self.navigationController pushViewController:listStoreViewController animated:YES];
}

#pragma mark - CCListConfigViewControllerDelegate methods

- (void)didChangedListConfig
{
    [self loadListItems];
    CCListView *view = (CCListView *)self.view;
    [view reloadListItemList];
}

#pragma mark - UINotificationCenter methods

- (void)applicationActive:(NSNotification *)note
{
    [_locationManager startUpdatingLocation];
    [_locationManager startUpdatingHeading];
}

- (void)applicationBackground:(NSNotification *)note
{
    [_locationManager stopUpdatingLocation];
    [_locationManager stopUpdatingHeading];
}

@end
