#import "CCListZone.h"

#import "CCGeohashHelper.h"

@interface CCListZone ()

@end

@implementation CCListZone

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.waitingTimeValue = (12 * 3600) + rand() % (12 * 3600);
    [self setNextRefreshDate];
}

- (void)updateNextRefreshDate:(BOOL)doubleWaitingTime
{
    if (kCCApplicationBackground) {
        if (doubleWaitingTime) {
            self.waitingTimeValue *= 1.2;
            self.waitingTimeValue = MIN((24 * 3600 * 180), self.waitingTimeValue);
        } else {
            self.waitingTimeValue /= 1.2;
            self.waitingTimeValue = MAX(20, self.waitingTimeValue);
        }
    }
    
    [self setNextRefreshDate];
}

- (void)setNextRefreshDate
{
    self.shortNextRefreshDate = [[NSDate date] dateByAddingTimeInterval:self.waitingTimeValue / 2];
    self.longNextRefreshDate = [[NSDate date] dateByAddingTimeInterval:self.waitingTimeValue];
}

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
