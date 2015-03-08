#import "_CCListZone.h"

@class CCListZone;

@interface CCListZone : _CCListZone {}

- (void)updateNextRefreshDate:(BOOL)doubleWaitingTime;
- (void)setNextRefreshDate;

- (void)updateNAddresses:(NSManagedObjectContext *)managedObjectContext;

+ (void)updateNAddressesForGeohashes:(NSSet *)geohashes list:(CCList *)list inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (CCListZone *)insertInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDict:(NSDictionary *)dict;

@end
