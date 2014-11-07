#import "_CCListZone.h"

@class CCListZone;

@interface CCListZone : _CCListZone {}

+ (CCListZone *)insertInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDict:(NSDictionary *)dict;

@end
