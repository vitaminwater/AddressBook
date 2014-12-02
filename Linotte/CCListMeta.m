#import "CCListMeta.h"

#import <HexColors/HexColor.h>

@interface CCListMeta ()

// Private interface goes here.

@end


@implementation CCListMeta

@synthesize content;

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
    NSArray *identifiers = [dictArray valueForKeyPath:@"@unionOfObjects.identifier"];
    
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
    
    NSArray *alreadyInstalledListMetaIdentifiers = [alreadyInstalledListMetas valueForKeyPath:@"@unionOfObjects.identifier"];
    
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
    NSError *error = nil;
    listMeta.identifier = dict[@"identifier"];
    listMeta.action = dict[@"action"];
    listMeta.uid = dict[@"uid"];
    listMeta.content = [NSJSONSerialization JSONObjectWithData:[dict[@"content"] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    if (error != nil) {
        NSLog(@"%@", error);
    }
}

@end
