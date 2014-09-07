#import "CCCategory.h"

#import <RestKit/RestKit.h>


@interface CCCategory ()

// Private interface goes here.

@end


@implementation CCCategory

+ (RKEntityMapping *)responseGETEntityMapping
{
    RKManagedObjectStore *managedObjectStore = [RKManagedObjectStore defaultStore];
    RKEntityMapping *entityMapping = [RKEntityMapping mappingForEntityForName:[self entityName] inManagedObjectStore:managedObjectStore];
    
    [entityMapping addAttributeMappingsFromArray:@[CCCategoryAttributes.identifier, CCCategoryAttributes.name]];
    
    return entityMapping;
}

+ (RKObjectMapping *)requestPOSTObjectMapping
{
    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    
    [objectMapping addAttributeMappingsFromArray:@[CCCategoryAttributes.identifier, CCCategoryAttributes.name]];
    
    return objectMapping;
}

+ (RKEntityMapping *)responsePOSTEntityMapping
{
    return nil;
}

@end
