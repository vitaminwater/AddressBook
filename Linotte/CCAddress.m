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

- (NSArray *)metasForActions:(NSArray *)actions
{
    NSMutableArray *metas = [@[] mutableCopy];
    for (NSString *action in actions) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"action = %@", action];
        [metas addObjectsFromArray:[[self.metas filteredSetUsingPredicate:predicate] allObjects]];
    }
    return metas;
}

+ (CCAddress *)insertOrUpdateInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDict:(NSDictionary *)dict
{
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier = %@", dict[@"identifier"]];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    NSArray *addresses = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        CCLog(@"%@", error);
        return nil;
    }
    
    CCAddress *address;
    if ([addresses count] > 0)
        address = [addresses firstObject];
    else {
        address = [CCAddress insertInManagedObjectContext:managedObjectContext];
    }
    [self setValuesForAddress:address fromLinotteDict:dict];
    return address;
}

+ (NSArray *)insertOrUpdateInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDictArray:(NSArray *)dictArray list:(CCList *)list
{
    NSError *error = nil;
    NSArray *identifiers = [dictArray valueForKeyPath:@"@unionOfObjects.identifier"];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
    if (list != nil) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY lists = %@ and identifier in %@", list, identifiers];
        [fetchRequest setPredicate:predicate];
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier in %@", identifiers];
        [fetchRequest setPredicate:predicate];
    }
    NSArray *alreadyInstalledAddresses = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        CCLog(@"%@", error);
        return @[];
    }
    
    NSArray *alreadyInstalledAddressIdentifiers = [alreadyInstalledAddresses valueForKeyPath:@"@unionOfObjects.identifier"]; // TODO: check is same order
    
    NSMutableArray *addresses = [@[] mutableCopy];
    for (NSDictionary *addressDict in dictArray) {
        NSUInteger addressIndex = [alreadyInstalledAddressIdentifiers indexOfObject:addressDict[@"identifier"]];
        CCAddress *address;
        
        if (addressIndex == NSNotFound) {
            address = [CCAddress insertInManagedObjectContext:managedObjectContext];
        } else {
            address = alreadyInstalledAddresses[addressIndex];
        }
        [self setValuesForAddress:address fromLinotteDict:addressDict];
        
        [addresses addObject:address];
    }
    return addresses;
}

+ (NSArray *)insertInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDictArray:(NSArray *)dictArray
{
    NSMutableArray *addresses = [@[] mutableCopy];
    for (NSDictionary *addressDict in dictArray) {
        CCAddress *address = [CCAddress insertInManagedObjectContext:managedObjectContext];
        [self setValuesForAddress:address fromLinotteDict:addressDict];
        
        [addresses addObject:address];
    }
    return addresses;
}

+ (NSArray *)updateUserDatasInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDictArray:(NSArray *)dictArray list:(CCList *)list shittyBlock:(void(^)(NSArray *addresses))shittyBlock
{
    NSError *error = nil;
    NSArray *identifiers = [dictArray valueForKeyPath:@"@unionOfObjects.identifier"];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
    if (list != nil) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY lists = %@ and identifier in %@", list, identifiers];
        [fetchRequest setPredicate:predicate];
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier in %@", identifiers];
        [fetchRequest setPredicate:predicate];
    }
    
    NSArray *addresses = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        CCLog(@"%@", error);
        return @[];
    }
    
    shittyBlock(addresses);
    
    NSArray *addressIdentifiers = [addresses valueForKeyPath:@"@unionOfObjects.identifier"];
    
    for (NSDictionary *addressDict in dictArray) {
        NSUInteger addressIndex = [addressIdentifiers indexOfObject:addressDict[@"identifier"]];
        if (addressIndex != NSNotFound) {
            CCAddress *address = addresses[addressIndex];
            address.note = addressDict[@"note"];
            address.notify = addressDict[@"notification"];
        }
    }
    return addresses;
}

+ (void)setValuesForAddress:(CCAddress *)address fromLinotteDict:(NSDictionary *)dict
{
    address.identifier = dict[@"identifier"];
    address.latitude = dict[@"latitude"];
    address.longitude = dict[@"longitude"];
    address.geohash = [CCGeohashHelper geohashFromCoordinates:CLLocationCoordinate2DMake([address.latitude doubleValue], [address.longitude doubleValue])];
    address.name = dict[@"name"];
    address.address = dict[@"address"];
    address.provider = dict[@"provider"];
    address.providerId = dict[@"provider_id"];
    address.note = dict[@"note"];
    address.notify = dict[@"notification"];
    address.isAuthor = dict[@"is_author"];
}

@end
