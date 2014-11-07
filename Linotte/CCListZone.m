#import "CCListZone.h"

#import "CCGeohashHelper.h"

@interface CCListZone ()

@end

@implementation CCListZone

+ (CCListZone *)insertInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDict:(NSDictionary *)dict
{
    CCListZone *listZone = [CCListZone insertInManagedObjectContext:managedObjectContext];
    NSString *geohash = dict[@"geohash"];
    CLLocationCoordinate2D coordinates = [CCGeohashHelper coordinatesFromGeohash:geohash];
    listZone.geohash = geohash;
    listZone.latitudeValue = coordinates.latitude;
    listZone.longitudeValue = coordinates.longitude;
    listZone.nAddresses = dict[@"n_addresses"];
    return listZone;
}

@end
