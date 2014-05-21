#import "CCCategories.h"

#import <RestKit/RestKit.h>

@interface CCCategories ()

@end


@implementation CCCategories

+ (RKObjectMapping *)requestObjectMapping
{
    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    
    [objectMapping addAttributeMappingsFromArray:@[CCCategoriesAttributes.identifier, CCCategoriesAttributes.name]];
    
    return objectMapping;
}

+ (RKEntityMapping *)responseEntityMapping
{
    RKManagedObjectStore *managedObjectStore = [RKManagedObjectStore defaultStore];
    RKEntityMapping *entityMapping = [RKEntityMapping mappingForEntityForName:[self entityName] inManagedObjectStore:managedObjectStore];
    
    [entityMapping addAttributeMappingsFromArray:@[CCCategoriesAttributes.name]];
    
    return entityMapping;
}

@end
