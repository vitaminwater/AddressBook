#import "_CCList.h"

#import <CoreLocation/CoreLocation.h>

@interface CCList : _CCList {}

- (NSArray *)getListZonesSortedByDistanceFromLocation:(CLLocationCoordinate2D)location;
- (NSArray *)metasForActions:(NSArray *)action;
- (void)updateNextRefreshDate:(BOOL)doubleWaitingTime;
- (void)setNextRefreshDate;

+ (CCList *)listWithIdentifier:(NSString *)identifier managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (CCList *)insertOrUpdateInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDict:(NSDictionary *)dict;
+ (NSArray *)insertInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDictArray:(NSArray *)dictArray;
+ (NSArray *)insertOrIgnoreInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDictArray:(NSArray *)dictArray;
+ (NSArray *)updateUserDatasInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDictArray:(NSArray *)dictArray shittyBlock:(void(^)(NSArray *lists))shittyBlock;

@end
