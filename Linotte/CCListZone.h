#import "_CCListZone.h"

@class CCListZone;

@interface CCListZone : _CCListZone {}

- (void)updateNextRefreshDate:(BOOL)doubleWaitingTime;
- (void)setNextRefreshDate;

+ (CCListZone *)insertInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDict:(NSDictionary *)dict;

@end
