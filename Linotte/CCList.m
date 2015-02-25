#import "CCList.h"

#import "CCListZone.h"

#import "CCGeohashHelper.h"
#import "CCLinotteEngineCoordinator.h"

@interface CCList ()

@end

@implementation CCList

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.localIdentifier = [[NSUUID UUID] UUIDString];
    self.lastUpdate = [NSDate date];
    self.waitingTimeValue = (12 * 3600) + rand() % (12 * 3600);
    [self setNextRefreshDate];
    
    [self setObservers];
}

- (void)awakeFromFetch
{
    [super awakeFromFetch];
    [self setObservers];
}

- (void)willTurnIntoFault
{
    [super willTurnIntoFault];
    [self unsetObservers];
}

- (void)setObservers
{
    [self addObserver:self forKeyPath:@"notify" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)unsetObservers
{
    [self removeObserver:self forKeyPath:@"notify"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"notify"]) {
        NSNumber *newValue = change[NSKeyValueChangeNewKey];
        if ([newValue boolValue] == YES)
            [[CCLinotteEngineCoordinator sharedInstance] startNotifying];
    }
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
        
        // TODO check number of common digits with variable geohash
        if (distance1 > distance2 || [geohash rangeOfString:listZone2.geohash].location == 0)
            return NSOrderedDescending;
        else if (distance1 < distance2 || [geohash rangeOfString:listZone1.geohash].location == 0)
            return NSOrderedAscending;
        return NSOrderedSame;
    }];
    
    return sortedListZones;
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

+ (CCList *)listWithIdentifier:(NSString *)identifier managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCList entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier = %@", identifier];
    [fetchRequest setPredicate:predicate];
    fetchRequest.fetchLimit = 1;
    NSArray *lists = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        CCLog(@"%@", error);
        return nil;
    }
    
    return [lists firstObject];
}

+ (CCList *)insertOrUpdateInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDict:(NSDictionary *)dict
{
    CCList *list = [self listWithIdentifier:dict[@"identifier"] managedObjectContext:managedObjectContext];
    if (list == nil) {
        list = [self insertInManagedObjectContext:managedObjectContext];
    }
    [self setValuesForlist:list fromLinotteDict:dict];
    return list;
}

+ (NSArray *)insertInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDictArray:(NSArray *)dictArray
{
    NSMutableArray *lists = [@[] mutableCopy];
    for (NSDictionary *listDict in dictArray) {
        CCList *list = [CCList insertInManagedObjectContext:managedObjectContext];
        [self setValuesForlist:list fromLinotteDict:listDict];
        
        [lists addObject:list];
    }
    return lists;
}

+ (NSArray *)insertOrIgnoreInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDictArray:(NSArray *)dictArray
{
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCList entityName]];
    
    NSArray *dictArrayIdentifiers = [dictArray valueForKeyPath:@"@unionOfObjects.identifier"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier in %@", dictArrayIdentifiers];
    [fetchRequest setPredicate:predicate];
    NSArray *lists = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        CCLog(@"%@", error);
        return nil;
    }
    
    NSArray *listIdentifiers = [lists valueForKeyPath:@"@unionOfObjects.identifier"];

    NSMutableArray *insertedLists = [@[] mutableCopy];
    for (NSDictionary *dict in dictArray) {
        if ([listIdentifiers containsObject:dict[@"identifier"]] == NO) {
            CCList *list = [self insertInManagedObjectContext:managedObjectContext];
            [list setNextRefreshDate];
            [self setValuesForlist:list fromLinotteDict:dict];
            [insertedLists addObject:list];
        }
    }
    return insertedLists;
}

+ (NSArray *)updateUserDatasInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDictArray:(NSArray *)dictArray shittyBlock:(void(^)(NSArray *lists))shittyBlock
{
    NSError *error = nil;
    NSArray *identifiers = [dictArray valueForKeyPath:@"@unionOfObjects.identifier"];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCList entityName]];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier in %@", identifiers];
    [fetchRequest setPredicate:predicate];

    NSArray *lists = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        CCLog(@"%@", error);
        return @[];
    }
    
    shittyBlock(lists);
    
    NSArray *listIdentifiers = [lists valueForKeyPath:@"@unionOfObjects.identifier"];
    
    for (NSDictionary *listUserDataDict in dictArray) {
        NSUInteger listIndex = [listIdentifiers indexOfObject:listUserDataDict[@"identifier"]];
        if (listIndex != NSNotFound) {
            CCList *list = lists[listIndex];
            list.notify = listUserDataDict[@"notification"];
        }
    }
    return lists;
}

+ (void)setValuesForlist:(CCList *)list fromLinotteDict:(NSDictionary *)dict
{
    list.identifier = dict[@"identifier"];
    list.name = dict[@"name"];
    list.icon = dict[@"icon"];
    list.author = dict[@"author"];
    list.authorIdentifier = dict[@"author_id"];
    list.notify = dict[@"notification"] ?: @NO;
    list.owned = dict[@"is_owned"];
    list.isdefault = dict[@"is_default"];
}

@end
