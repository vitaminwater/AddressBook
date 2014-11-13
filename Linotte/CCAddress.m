#import "CCAddress.h"

#import "CCGeohashHelper.h"

@interface CCAddress ()

@end

@implementation CCAddress

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.localIdentifier = [[NSUUID UUID] UUIDString];
}

+ (CCAddress *)insertInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDict:(NSDictionary *)dict
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier = %@", dict[@"identifier"]];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    NSArray *addresses = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    
    CCAddress *address;
    if ([addresses count] > 0)
        address = [addresses firstObject];
    else {
        address = [CCAddress insertInManagedObjectContext:managedObjectContext];
        address.identifier = dict[@"identifier"];
    }
    address.latitude = dict[@"latitude"];
    address.longitude = dict[@"longitude"];
    address.geohash = [CCGeohashHelper geohashFromCoordinates:CLLocationCoordinate2DMake([address.latitude doubleValue], [address.longitude doubleValue])];
    address.name = dict[@"name"];
    address.address = dict[@"address"];
    address.provider = dict[@"provider"];
    address.providerId = dict[@"provider_id"];
    address.note = dict[@"note"];
    address.notify = dict[@"notification"];
    return address;
}

@end
