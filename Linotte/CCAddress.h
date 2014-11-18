#import "_CCAddress.h"

@interface CCAddress : _CCAddress {}

+ (CCAddress *)insertOrUpdateInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDict:(NSDictionary *)dict;
+ (NSArray *)insertOrUpdateInManageObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDictArray:(NSArray *)dictArray list:(CCList *)list;
+ (NSArray *)insertInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDictArray:(NSArray *)dictArray;
+ (NSArray *)updateUserDatasInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDictArray:(NSArray *)dictArray list:(CCList *)list;

@end
