#import "CCList.h"

#import "CCListZone.h"

#import "CCGeohashHelper.h"

@interface CCList ()

@end

@implementation CCList

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.localIdentifier = [[NSUUID UUID] UUIDString];
}

- (NSArray *)getListZonesSortedByDistanceFromLocation:(CLLocationCoordinate2D)location
{
    if ([self.zones count] == 0)
        return nil;
    
    NSString *geohash = [CCGeohashHelper geohashFromCoordinates:location];
    CLLocation *lastLocation = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
    NSArray *sortedListZones = [self.zones.allObjects sortedArrayUsingComparator:^NSComparisonResult(CCListZone *listZone1, CCListZone *listZone2) {
        CLLocation *location1 = [[CLLocation alloc] initWithLatitude:listZone1.latitudeValue longitude:listZone1.longitudeValue];
        CLLocation *location2 = [[CLLocation alloc] initWithLatitude:listZone2.latitudeValue longitude:listZone2.longitudeValue];
        
        CLLocationDistance distance1 = [location1 distanceFromLocation:lastLocation];
        CLLocationDistance distance2 = [location2 distanceFromLocation:lastLocation];
        
        if (distance1 > distance2 || [geohash rangeOfString:listZone2.geohash].location == 0)
            return NSOrderedDescending;
        else if (distance1 < distance2 || [geohash rangeOfString:listZone1.geohash].location == 0)
            return NSOrderedAscending;
        return NSOrderedSame;
    }];
    
    /*for (CCListZone *listZone in sortedListZones) {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:listZone.latitudeValue longitude:listZone.longitudeValue];
        NSLog(@"%f %f %@ %f", listZone.latitudeValue, listZone.longitudeValue, listZone.geohash, [location distanceFromLocation:lastLocation]);
    }*/
    
    return sortedListZones;
}

+ (CCList *)insertInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDict:(NSDictionary *)dict
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCList entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier = %@", dict[@"identifier"]];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    NSArray *lists = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    
    CCList *list;
    if ([lists count] > 0)
        list = [lists firstObject];
    else {
        list = [self insertInManagedObjectContext:managedObjectContext];
        list.identifier = dict[@"identifier"];
    }
    list.name = dict[@"name"];
    list.icon = dict[@"icon"];
    list.provider = dict[@"provider"];
    list.providerId = dict[@"provider_id"];
    list.owned = @(NO);
    return list;
}

@end
