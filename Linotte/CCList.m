#import "CCList.h"

#import "CCListZone.h"

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
    
    CLLocation *lastLocation = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
    return [self.zones.allObjects sortedArrayUsingComparator:^NSComparisonResult(CCListZone *listZone1, CCListZone *listZone2) {
        CLLocation *location1 = [[CLLocation alloc] initWithLatitude:listZone1.latitudeValue longitude:listZone1.longitudeValue];
        CLLocation *location2 = [[CLLocation alloc] initWithLatitude:listZone2.latitudeValue longitude:listZone2.longitudeValue];
        
        CLLocationDistance distance1 = [location1 distanceFromLocation:lastLocation];
        CLLocationDistance distance2 = [location2 distanceFromLocation:lastLocation];
        
        if (distance1 > distance2)
            return NSOrderedDescending;
        else if (distance1 > distance2)
            return NSOrderedAscending;
        return NSOrderedSame;
    }];
}

+ (CCList *)insertInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDict:(NSDictionary *)dict
{
    CCList *list = [self insertInManagedObjectContext:managedObjectContext];
    list.identifier = dict[@"identifier"];
    list.name = dict[@"name"];
    list.icon = dict[@"icon"];
    list.provider = dict[@"provider"];
    list.providerId = dict[@"provider_id"];
    list.owned = @(NO);
    return list;
}

@end
