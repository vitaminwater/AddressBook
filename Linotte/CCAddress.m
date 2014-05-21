#import "CCAddress.h"

#import <RestKit/RestKit.h>

#import "CCCategories.h"


@interface CCAddress ()

// Private interface goes here.

@end


@implementation CCAddress

#pragma mark - RestKit mapping

+ (RKObjectMapping *)requestObjectMapping
{
    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    
    [objectMapping addAttributeMappingsFromArray:@[CCAddressAttributes.address, CCAddressAttributes.latitude, CCAddressAttributes.longitude, CCAddressAttributes.name]];
    
    RKObjectMapping *categoriesObjectMapping = [CCCategories requestObjectMapping];
    [objectMapping addRelationshipMappingWithSourceKeyPath:@"categories" mapping:categoriesObjectMapping];
    
    return objectMapping;
}

+ (RKEntityMapping *)responseEntityMapping
{
    RKManagedObjectStore *managedObjectStore = [RKManagedObjectStore defaultStore];
    RKEntityMapping *entityMapping = [RKEntityMapping mappingForEntityForName:[self entityName] inManagedObjectStore:managedObjectStore];
    
    [entityMapping addAttributeMappingsFromArray:@[CCAddressAttributes.identifier]];
    return entityMapping;
}

@end
