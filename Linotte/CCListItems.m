//
//  CCListItems.m
//  Linotte
//
//  Created by stant on 10/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListItems.h"

#import <CoreLocation/CoreLocation.h>

#import <RestKit/RestKit.h>

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

- (NSString *)iconPrefix;

@end

@implementation CCListItem

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
    self.name = _address.name;
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

@end













/*
 * List list item
 */
@interface CCListItemList()

@end

@implementation CCListItemList

- (void)setList:(CCList *)list
{
    _list = list;
    self.name = [NSString stringWithFormat:@"Liste: %@", _list.name];
}

- (void)setLocation:(CLLocation *)location
{
    [super setLocation:location];
    
    if (self.location == nil)
        return;
    
    NSManagedObjectContext *managedObjectContext = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    
    NSArray *geohashesComp = geohashLimit(self.location, kCCSmallGeohashLength);
    
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
        double newDistance = [self.location distanceFromLocation:addressLocation];
        if (newDistance < distance || closestLocation == nil)
            closestLocation = addressLocation;
    }
    self.itemLocation = closestLocation;
}

- (CCListItemType)type
{
    return CCListItemTypeList;
}

- (NSString *)iconPrefix
{
    return @"list_pin";
}

@end
