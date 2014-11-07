#import "_CCAddress.h"

@interface CCAddress : _CCAddress {}

+ (CCAddress *)insertInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDict:(NSDictionary *)dict;

@end
