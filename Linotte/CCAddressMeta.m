#import "CCAddressMeta.h"

#import "CCCoreDataStack.h"

@interface CCAddressMeta ()

// Private interface goes here.

@end


@implementation CCAddressMeta

@synthesize content;

+ (CCAddressMeta *)insertOrUpdateInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDict:(NSDictionary *)dict
{
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddressMeta entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier = %@", dict[@"identifier"]];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    NSArray *addressMetas = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        CCLog(@"%@", error);
        return nil;
    }
    
    CCAddressMeta *addressMeta;
    if ([addressMetas count] > 0)
        addressMeta = [addressMetas firstObject];
    else {
        addressMeta = [CCAddressMeta insertInManagedObjectContext:managedObjectContext];
    }
    [self setValuesForAddressMeta:addressMeta fromLinotteDict:dict];
    return addressMeta;
}

+ (NSArray *)insertOrUpdateInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDictArray:(NSArray *)dictArray list:(CCList *)list
{
    NSError *error = nil;
    NSArray *identifiers = [dictArray valueForKeyPath:@"@unionOfObjects.identifier"];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddressMeta entityName]];
    if (list != nil) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"list = %@ and identifier in %@", list, identifiers];
        [fetchRequest setPredicate:predicate];
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier in %@", identifiers];
        [fetchRequest setPredicate:predicate];
    }
    NSArray *alreadyInstalledAddressMetas = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        CCLog(@"%@", error);
        return @[];
    }
    
    NSArray *alreadyInstalledAddressMetaIdentifiers = [alreadyInstalledAddressMetas valueForKeyPath:@"@unionOfObjects.identifier"];
    
    NSMutableArray *addressMetas = [@[] mutableCopy];
    for (NSDictionary *addressDict in dictArray) {
        NSUInteger addressMetaIndex = [alreadyInstalledAddressMetaIdentifiers indexOfObject:addressDict[@"identifier"]];
        CCAddressMeta *addressMeta;
        
        if (addressMetaIndex == NSNotFound) {
            addressMeta = [CCAddressMeta insertInManagedObjectContext:managedObjectContext];
        } else {
            addressMeta = alreadyInstalledAddressMetas[addressMetaIndex];
        }
        [self setValuesForAddressMeta:addressMeta fromLinotteDict:addressDict];
        
        [addressMetas addObject:addressMeta];
    }
    return addressMetas;
}

+ (NSArray *)insertInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDictArray:(NSArray *)dictArray
{
    NSMutableArray *addressMetas = [@[] mutableCopy];
    for (NSDictionary *addressMetaDict in dictArray) {
        CCAddressMeta *addressMeta = [CCAddressMeta insertInManagedObjectContext:managedObjectContext];
        [self setValuesForAddressMeta:addressMeta fromLinotteDict:addressMetaDict];
        
        [addressMetas addObject:addressMeta];
    }
    return addressMetas;
}

+ (void)setValuesForAddressMeta:(CCAddressMeta *)addressMeta fromLinotteDict:(NSDictionary *)dict
{
    NSError *error = nil;
    addressMeta.identifier = dict[@"identifier"];
    addressMeta.action = dict[@"action"];
    addressMeta.uid = dict[@"uid"];
    NSDictionary *content = [NSJSONSerialization JSONObjectWithData:[dict[@"content"] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    addressMeta.content = content;
    if (error != nil) {
        NSLog(@"%@", error);
    }
}

@end
