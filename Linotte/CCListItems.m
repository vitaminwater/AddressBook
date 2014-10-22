//
//  CCListItems.m
//  Linotte
//
//  Created by stant on 10/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListItems.h"

#import <CoreLocation/CoreLocation.h>

#import "CCCoreDataStack.h"

#import "NSString+CCLocalizedString.h"

#import "CCAddress.h"
#import "CCList.h"

#import "CCGeohashHelper.h"

#define kCCSmallGeohashLength 13

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

NSArray *geohashLimit(CLLocation *location, NSUInteger digits) // TODO cache result
{
    NSArray *geohashes = [CCGeohashHelper geohashGridSurroundingCoordinate:location.coordinate radius:1 digits:digits all:YES];
    NSMutableArray *geohashesComp = [@[] mutableCopy];
    for (NSString *geohash in geohashes) {
        NSString *subGeohash = [geohash substringToIndex:digits];
        [geohashesComp addObject:subGeohash];
    }
    return geohashesComp;
}









/*
 * Data model classes
 */

@interface CCListItem()

@property(nonatomic, assign)BOOL farAway;
@property(nonatomic, strong)CLLocation *itemLocation;

- (NSString *)iconPrefix;

@end

@implementation CCListItem

- (void)refreshData {}

- (double)distance
{
    if (_farAway)
        return 10000; // TODO find right distance based on geohash length
    return [self.location distanceFromLocation:self.itemLocation];
}

- (double)angleForHeading:(CLHeading *)heading
{
    float angle = getHeadingForDirectionFromCoordinate(self.location.coordinate, self.itemLocation.coordinate);
    return angle - heading.magneticHeading;
}

- (UIImage *)icon
{
    CGFloat distance = [self distance];
    NSArray *distanceColors = kCCLinotteColors;
    NSString *imagePath = nil;
    int distanceColorIndex = distance / 500;
    distanceColorIndex = MIN(distanceColorIndex, (int)[distanceColors count] - 1);
    if (distance > 0) {
        NSString *color = distanceColors[distanceColorIndex];
        imagePath = [NSString stringWithFormat:@"%@_%@", [self iconPrefix], [color substringFromIndex:1]];
    } else
        imagePath = [NSString stringWithFormat:@"%@_neutral", [self iconPrefix]];
    return [UIImage imageNamed:imagePath];
}

- (NSString *)iconPrefix
{
    return @"gmap_pin";
}

- (NSString *)distanceInfo
{
    if (self.distance < 0)
        return NSLocalizedString(@"DISTANCE_UNAVAILABLE", @"");
    
    if (self.farAway)
        return NSLocalizedString(@"DISTANCE_TOO_FAR", @"");
    
    double distance = self.distance;
    
    if (distance > 1000) {
        distance /= 1000;
        return [NSString stringWithFormat:@"%.02f km", distance];
    } else {
        distance = (int)distance;
        return [NSString stringWithFormat:@"%d m", (int)distance];
    }
}

@end










/*
 * Address list item
 */
@interface CCListItemAddress()

@end

@implementation CCListItemAddress

- (void)setAddress:(CCAddress *)address
{
    _address = address;
    self.itemLocation = [[CLLocation alloc] initWithLatitude:_address.latitudeValue longitude:_address.longitudeValue];
}

- (void)setLocation:(CLLocation *)location
{
    [super setLocation:location];
    
    if (location == nil)
        return;
    
    NSArray *geohashesComp = geohashLimit(self.location, kCCSmallGeohashLength);
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF = %@", [_address.geohash substringToIndex:kCCSmallGeohashLength]];
    
    if ([[geohashesComp filteredArrayUsingPredicate:predicate] count] == 0)
        self.farAway = YES;
    else
        self.farAway = NO;
}

- (CCListItemType)type
{
    return CCListItemTypeAddress;
}

#pragma mark - getter methods

- (NSString *)name
{
    return _address.name;
}

- (NSString *)info
{
    NSString *info = [self distanceInfo];
    
    if ([_address.lists count]) {
        NSMutableString *listInfo = [NSLocalizedString(@"ADDRESS_LIST_IN", @"") mutableCopy];
        for (CCList *list in _address.lists) {
            [listInfo appendFormat:@"%@, ", list.name];
        }
        [listInfo replaceCharactersInRange:(NSRange){[listInfo length] - 2, 2} withString:@""];
        info = [NSString stringWithFormat:@"%@\n%@", listInfo, info];
    }
    
    return info;
}

- (BOOL)notify
{
    return _address.notifyValue;
}

@end













/*
 * List list item
 */

@implementation CCListItemList
{
    CCAddress *_closestAddress;
}

- (void)setList:(CCList *)list
{
    _list = list;
}

- (void)setLocation:(CLLocation *)location
{
    [super setLocation:location];
    [self refreshListData];
}

- (CCListItemType)type
{
    return CCListItemTypeList;
}

- (NSString *)iconPrefix
{
    return @"list_pin";
}

#pragma mark - public methods

- (void)addAddress:(CCAddress *)address
{
    if (self.location == nil)
        return;
    
    NSArray *geohashesComp = geohashLimit(self.location, kCCSmallGeohashLength);
    BOOL tooFar = YES;
    for (NSString *geohash in geohashesComp) {
        if ([address.geohash hasPrefix:geohash]) {
            tooFar = NO;
            break;
        }
    }
    if (tooFar)
        return;
    
    CLLocation *addressLocation = [[CLLocation alloc] initWithLatitude:address.latitudeValue longitude:address.longitudeValue];
    double newDistance = [self.location distanceFromLocation:addressLocation];
    if (self.farAway || newDistance < self.distance) {
        self.itemLocation = addressLocation;
        _closestAddress = address;
        self.farAway = NO;
    }
}

- (void)removeAddress:(CCAddress *)address
{
    if (_closestAddress == address) {
        [self refreshListData];
    }
}

- (void)refreshData
{
    [self refreshListData];
}

#pragma mark - private methods

- (void)refreshListData
{
    if (self.location == nil)
        return;
    
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    
    NSArray *geohashesComp = geohashLimit(self.location, kCCSmallGeohashLength);
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(ANY lists = %@) AND (geohash BEGINSWITH %@ OR geohash BEGINSWITH %@ OR geohash BEGINSWITH %@ OR geohash BEGINSWITH %@ OR geohash BEGINSWITH %@ OR geohash BEGINSWITH %@ OR geohash BEGINSWITH %@ OR geohash BEGINSWITH %@ OR geohash BEGINSWITH %@)", _list, geohashesComp[0], geohashesComp[1], geohashesComp[2], geohashesComp[3], geohashesComp[4], geohashesComp[5], geohashesComp[6], geohashesComp[7], geohashesComp[8]]; // TODO store pre calculated small geohash in model !
    [fetchRequest setPredicate:predicate];
    
    NSArray *addresses = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    
    if ([addresses count] == 0) {
        self.itemLocation = nil;
        _closestAddress = nil;
        self.farAway = YES;
        return;
    }
    self.farAway = NO;
    
    CLLocation *closestLocation = nil;
    CCAddress *closestAddress = nil;
    double distance = DBL_MAX;
    for (CCAddress *address in addresses) {
        CLLocation *addressLocation = [[CLLocation alloc] initWithLatitude:address.latitudeValue longitude:address.longitudeValue];
        double newDistance = [self.location distanceFromLocation:addressLocation];
        if (closestLocation == nil || newDistance < distance) {
            closestLocation = addressLocation;
            closestAddress = address;
            distance = newDistance;
        }
    }
    self.itemLocation = closestLocation;
    _closestAddress = closestAddress;
}

#pragma mark - getter methods

- (NSString *)name
{
    return _list.name;
}

- (NSString *)info
{
    NSString *distanceInfo = [self distanceInfo];
    
    NSUInteger nAddresses = [_list.addresses count];
    NSString *localizedKey = nAddresses > 1 ? @"LIST_INFO_PLURAL" : @"LIST_INFO";
    NSString *listInfo = [NSString localizedStringByReplacingFromDictionnary:@{@"[nAddress]" : [@(nAddresses) stringValue]} localizedKey:localizedKey];
    
    if ([_list.addresses count] == 0)
        return listInfo;
    return [NSString stringWithFormat:@"%@\n%@", listInfo, distanceInfo];
}

- (BOOL)notify
{
    return _list.notifyValue;
}

@end
