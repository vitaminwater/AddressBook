#import "_CCAddressMeta.h"

@interface CCAddressMeta : _CCAddressMeta {}

+ (CCAddressMeta *)insertOrUpdateInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDict:(NSDictionary *)dict;
+ (NSArray *)insertOrUpdateInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDictArray:(NSArray *)dictArray list:(CCList *)list;
+ (NSArray *)insertInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDictArray:(NSArray *)dictArray;

@end
