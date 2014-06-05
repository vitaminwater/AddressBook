//
//  CCListViewController.m
//  Linotte
//
//  Created by stant on 06/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListViewController.h"

#import <objc/runtime.h>

#import "CCRestKit.h"

#import "CCOutputViewController.h"

#import "CCListView.h"


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

@interface CCListViewController ()
{
    CLLocationManager *_locationManager;
    CLLocation *_currentLocation;
    CLHeading *_currentHeading;
}

@property(nonatomic, strong)NSMutableArray *addresses;

@end

@implementation CCListViewController

- (id)init
{
    self = [super init];
    if (self) {
        NSManagedObjectContext *managedObjectContext = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
        
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
        
        NSArray *addresses = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
        _addresses = [addresses mutableCopy];
        
        [_addresses sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [self nameSortMethod:obj1 obj2:obj2];
        }];
    }
    return self;
}

- (void)loadView
{
    CCListView *listView = [[CCListView alloc] initWithHelpOn:[_addresses count] == 0];
    listView.delegate = self;
    self.view = listView;
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

#pragma mark - sort methods

- (NSComparisonResult)nameSortMethod:(CCAddress *)obj1 obj2:(CCAddress *)obj2
{
    return [obj1.name compare:obj2.name options:NSCaseInsensitiveSearch];
}

- (NSComparisonResult)distanceSortMethod:(CCAddress *)obj1 obj2:(CCAddress *)obj2
{
    CLLocation *coordinate1 = [[CLLocation alloc] initWithLatitude:obj1.latitudeValue longitude:obj1.longitudeValue];
    CLLocation *coordinate2 = [[CLLocation alloc] initWithLatitude:obj2.latitudeValue longitude:obj2.longitudeValue];
    
    double distance1 = [coordinate1 distanceFromLocation:_currentLocation];
    double distance2 = [coordinate2 distanceFromLocation:_currentLocation];
    
    return [@(distance1) compare:@(distance2)];
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    _currentLocation = location;
    
    __weak CCListViewController *weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [_addresses sortUsingComparator:^NSComparisonResult(CCAddress *obj1, CCAddress *obj2) {
            return [weakSelf distanceSortMethod:obj1 obj2:obj2];
        }];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [((CCListView *)weakSelf.view) reloadVisibleAddresses];
        });
    });
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    _currentHeading = newHeading;
    [((CCListView *)self.view) reloadVisibleAddresses];
}

#pragma mark - public methods

- (void)addressAdded:(CCAddress *)address
{
    NSUInteger newIndex;
    
    if (!_currentLocation) {
        newIndex = [_addresses indexOfObject:address
                    inSortedRange:(NSRange){0, [_addresses count]}
                          options:NSBinarySearchingInsertionIndex
                  usingComparator:^NSComparisonResult(id obj1, id obj2) {
                      return [self nameSortMethod:obj1 obj2:obj2];
                  }];
    } else {
        newIndex = [_addresses indexOfObject:address
                               inSortedRange:(NSRange){0, [_addresses count]}
                                     options:NSBinarySearchingInsertionIndex
                             usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                 return [self distanceSortMethod:obj1 obj2:obj2];
                             }];
    }
    
    [_addresses insertObject:address atIndex:newIndex];
    
    [((CCListView *)self.view) insertAddressAtIndex:newIndex];
    
    CCOutputViewController *outputViewController = [[CCOutputViewController alloc] initWithAddress:address];
    [self.navigationController pushViewController:outputViewController animated:YES];
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
        return;
    
    NSNumber *index = objc_getAssociatedObject(alertView, @"index");
    
    NSError *error;
    NSManagedObjectContext *managedObjectContext = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    CCAddress *address = _addresses[[index intValue]];
    [_addresses removeObject:address];
    [managedObjectContext deleteObject:address];
    if ([managedObjectContext saveToPersistentStore:&error] == NO) {
        NSLog(@"%@", error);
        return;
    }
    [((CCListView *)self.view) deleteAddressAtIndex:[index intValue]];
}

#pragma mark - CCListViewDelegate methods

- (void)didSelectAddressAtIndex:(NSUInteger)index
{
    CCAddress *address = _addresses[index];
    CCOutputViewController *outputViewController = [[CCOutputViewController alloc] initWithAddress:address];
    [self.navigationController pushViewController:outputViewController animated:YES];
}

- (void)deleteAddressAtIndex:(NSUInteger)index
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NOTIF_ADDELETE", @"") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"NOTIF_ADDELETE_N", @"") otherButtonTitles:NSLocalizedString(@"NOTIF_ADDELETE_Y", @""), nil];
    [alertView show];
    
    objc_setAssociatedObject(alertView, @"index", @(index), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (double)distanceForAddressAtIndex:(NSUInteger)index
{
    if (_currentLocation) {
        CCAddress *address = _addresses[index];
        CLLocation *coordinate = [[CLLocation alloc] initWithLatitude:address.latitudeValue longitude:address.longitudeValue];
        return [_currentLocation distanceFromLocation:coordinate];
    }
    return -1;
}

- (double)angleForAddressAtIndex:(NSUInteger)index
{
    if (_currentLocation) {
        CCAddress *address = _addresses[index];
        CLLocation *coordinate = [[CLLocation alloc] initWithLatitude:address.latitudeValue longitude:address.longitudeValue];
        float angle = getHeadingForDirectionFromCoordinate(_currentLocation.coordinate, coordinate.coordinate);
        return angle - _currentHeading.magneticHeading;
    }
    return 0;
}

- (NSString *)nameForAddressAtIndex:(NSUInteger)index
{
    CCAddress *address = _addresses[index];
    return address.name;
}

- (NSString *)addressForAddressAtIndex:(NSUInteger)index
{
    CCAddress *address = _addresses[index];
    return address.address;
}

- (NSDate *)lastNotifForAddressAtIndex:(NSUInteger)index
{
    CCAddress *address = _addresses[index];
    return address.lastnotif;
}

- (NSUInteger)numberOfAddresses
{
    return [_addresses count];
}

@end
