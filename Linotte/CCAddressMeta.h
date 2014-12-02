#import "_CCAddressMeta.h"

#import "CCMetaProtocol.h"

@interface CCAddressMeta : _CCAddressMeta<CCMetaProtocol> {}

@property (nonatomic, strong)NSDictionary *content;

+ (CCAddressMeta *)insertOrUpdateInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDict:(NSDictionary *)dict;
+ (NSArray *)insertOrUpdateInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDictArray:(NSArray *)dictArray list:(CCList *)list;
+ (NSArray *)insertInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDictArray:(NSArray *)dictArray;

@end
