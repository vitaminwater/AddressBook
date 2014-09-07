#import "CCAddressMeta.h"

#import <RestKit/RestKit.h>

@interface CCAddressMeta ()

// Private interface goes here.

@end


@implementation CCAddressMeta

+ (RKEntityMapping *)responseGETEntityMapping
{
    RKManagedObjectStore *managedObjectStore = [RKManagedObjectStore defaultStore];
    RKEntityMapping *entityMapping = [RKEntityMapping mappingForEntityForName:[self entityName] inManagedObjectStore:managedObjectStore];
    
    [entityMapping addAttributeMappingsFromArray:@[CCAddressMetaAttributes.identifier, CCAddressMetaAttributes.name, CCAddressMetaAttributes.internal_name, CCAddressMetaAttributes.value]];
    
    return entityMapping;
}

+ (RKObjectMapping *)requestPOSTObjectMapping
{
    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    
    [objectMapping addAttributeMappingsFromArray:@[CCAddressMetaAttributes.name, CCAddressMetaAttributes.internal_name, CCAddressMetaAttributes.value]];
    
    return objectMapping;
}

+ (RKEntityMapping *)responsePOSTEntityMapping
{
    RKManagedObjectStore *managedObjectStore = [RKManagedObjectStore defaultStore];
    RKEntityMapping *entityMapping = [RKEntityMapping mappingForEntityForName:[self entityName] inManagedObjectStore:managedObjectStore];
    
    [entityMapping addAttributeMappingsFromArray:@[CCAddressMetaAttributes.identifier]];
    return entityMapping;
}

@end
