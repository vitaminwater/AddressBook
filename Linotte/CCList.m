#import "CCList.h"

#import <RestKit/RestKit.h>

#import "CCAddress.h"

@interface CCList ()

@end


@implementation CCList

+ (RKEntityMapping *)responseGETEntityMapping
{
    RKManagedObjectStore *managedObjectStore = [RKManagedObjectStore defaultStore];
    RKEntityMapping *entityMapping = [RKEntityMapping mappingForEntityForName:[self entityName] inManagedObjectStore:managedObjectStore];
    
    [entityMapping addAttributeMappingsFromArray:@[CCAddressAttributes.identifier, CCListAttributes.name, CCListAttributes.icon, CCListAttributes.provider]];
    [entityMapping addAttributeMappingsFromDictionary:@{@"provider_id" : CCListAttributes.providerId}];
    
    RKObjectMapping *addressesObjectMapping = [CCAddress responseGETEntityMapping];
    [entityMapping addRelationshipMappingWithSourceKeyPath:@"addresses" mapping:addressesObjectMapping];

    return entityMapping;
}

+ (RKObjectMapping *)requestPOSTObjectMapping
{
    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    
    [objectMapping addAttributeMappingsFromArray:@[CCListAttributes.name]];
    
    RKObjectMapping *addressesObjectMapping = [CCAddress requestPOSTObjectSlugMapping];
    [objectMapping addRelationshipMappingWithSourceKeyPath:@"addresses" mapping:addressesObjectMapping];
    
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
