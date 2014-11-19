#import "CCListMeta.h"

#import <HexColors/HexColor.h>

@interface CCListMeta ()

// Private interface goes here.

@end


@implementation CCListMeta

+ (CCListMeta *)insertOrUpdateInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDict:(NSDictionary *)dict
{
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCListMeta entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier = %@", dict[@"identifier"]];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    NSArray *listMetas = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        CCLog(@"%@", error);
        return nil;
    }
    
    CCListMeta *listMeta;
    if ([listMetas count] > 0)
        listMeta = [listMetas firstObject];
    else {
        listMeta = [CCListMeta insertInManagedObjectContext:managedObjectContext];
    }
    [self setValuesForlistMeta:listMeta fromLinotteDict:dict];
    return listMeta;
}

+ (NSArray *)insertOrUpdateInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDictArray:(NSArray *)dictArray list:(CCList *)list
{
    NSError *error = nil;
    NSArray *identifiers = [dictArray valueForKeyPath:@"identifier"];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCListMeta entityName]];
    if (list != nil) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"list = %@ and identifier in %@", list, identifiers];
        [fetchRequest setPredicate:predicate];
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier in %@", identifiers];
        [fetchRequest setPredicate:predicate];
    }
    NSArray *alreadyInstalledListMetas = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        CCLog(@"%@", error);
        return @[];
    }
    
    NSArray *alreadyInstalledListMetaIdentifiers = [alreadyInstalledListMetas valueForKeyPath:@"identifier"];
    
    NSMutableArray *listMetas = [@[] mutableCopy];
    for (NSDictionary *listMetaDict in dictArray) {
        NSUInteger listMetaIndex = [alreadyInstalledListMetaIdentifiers indexOfObject:listMetaDict[@"identifier"]];
        CCListMeta *listMeta;
        
        if (listMetaIndex == NSNotFound) {
            listMeta = [CCListMeta insertInManagedObjectContext:managedObjectContext];
        } else {
            listMeta = alreadyInstalledListMetas[listMetaIndex];
        }
        [self setValuesForlistMeta:listMeta fromLinotteDict:listMetaDict];
        
        [listMetas addObject:listMeta];
    }
    return listMetas;
}

+ (NSArray *)insertInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDictArray:(NSArray *)dictArray
{
    NSMutableArray *listMetas = [@[] mutableCopy];
    for (NSDictionary *listMetaDict in dictArray) {
        CCListMeta *listMeta = [CCListMeta insertInManagedObjectContext:managedObjectContext];
        [self setValuesForlistMeta:listMeta fromLinotteDict:listMetaDict];
        
        [listMetas addObject:listMeta];
    }
    return listMetas;
}

+ (void)setValuesForlistMeta:(CCListMeta *)listMeta fromLinotteDict:(NSDictionary *)dict
{
    listMeta.identifier = dict[@"identifier"];
    listMeta.name = dict[@"name"];
    listMeta.internalName = dict[@"internal_name"];
    listMeta.value = dict[@"value"];
}

@end
