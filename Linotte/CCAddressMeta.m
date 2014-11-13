#import "CCAddressMeta.h"

#import "CCCoreDataStack.h"

@interface CCAddressMeta ()

// Private interface goes here.

@end


@implementation CCAddressMeta

+ (CCAddressMeta *)insertInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDict:(NSDictionary *)dict
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddressMeta entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier = %@", dict[@"identifier"]];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    NSArray *addressMetas = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    
    CCAddressMeta *addressMeta;
    if ([addressMetas count] > 0)
        addressMeta = [addressMetas firstObject];
    else {
        addressMeta = [CCAddressMeta insertInManagedObjectContext:managedObjectContext];
        addressMeta.identifier = dict[@"identifier"];
    }
    addressMeta.name = dict[@"name"];
    addressMeta.internalName = dict[@"internal_name"];
    addressMeta.value = dict[@"value"];
    return addressMeta;
}

@end
