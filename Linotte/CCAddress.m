#import "CCAddress.h"

#import <RestKit/RestKit.h>

#import "CCCategory.h"


@interface CCAddress ()

// Private interface goes here.

@end


@implementation CCAddress

#pragma mark - RestKit mapping

+ (RKObjectMapping *)requestPOSTObjectMapping
{
    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    
    [objectMapping addAttributeMappingsFromArray:@[CCAddressAttributes.address, CCAddressAttributes.latitude, CCAddressAttributes.longitude, CCAddressAttributes.name, CCAddressAttributes.provider]];
    [objectMapping addAttributeMappingsFromDictionary:@{CCAddressAttributes.providerId : @"provider_id"}];
    
    RKObjectMapping *categoriesObjectMapping = [CCCategory requestObjectMapping];
    [objectMapping addRelationshipMappingWithSourceKeyPath:@"categories" mapping:categoriesObjectMapping];
    
    return objectMapping;
}

+ (RKEntityMapping *)responsePOSTEntityMapping
{
    RKManagedObjectStore *managedObjectStore = [RKManagedObjectStore defaultStore];
    RKEntityMapping *entityMapping = [RKEntityMapping mappingForEntityForName:[self entityName] inManagedObjectStore:managedObjectStore];
    
    [entityMapping addAttributeMappingsFromArray:@[CCAddressAttributes.identifier]];
    return entityMapping;
}

@end
