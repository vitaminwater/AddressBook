#import "CCListMeta.h"

#import <HexColors/HexColor.h>

#import <RestKit/RestKit.h>

@interface CCListMeta ()

// Private interface goes here.

@end


@implementation CCListMeta

+ (RKEntityMapping *)responseGETEntityMapping
{
    RKManagedObjectStore *managedObjectStore = [RKManagedObjectStore defaultStore];
    RKEntityMapping *entityMapping = [RKEntityMapping mappingForEntityForName:[self entityName] inManagedObjectStore:managedObjectStore];
    
    [entityMapping addAttributeMappingsFromArray:@[CCListMetaAttributes.identifier, CCListMetaAttributes.name, CCListMetaAttributes.internal_name, CCListMetaAttributes.value]];
    
    return entityMapping;
}

+ (RKObjectMapping *)requestPOSTObjectMapping
{
    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    
    [objectMapping addAttributeMappingsFromArray:@[CCListMetaAttributes.name, CCListMetaAttributes.internal_name, CCListMetaAttributes.value]];
    
    return objectMapping;
}

+ (RKEntityMapping *)responsePOSTEntityMapping
{
    RKManagedObjectStore *managedObjectStore = [RKManagedObjectStore defaultStore];
    RKEntityMapping *entityMapping = [RKEntityMapping mappingForEntityForName:[self entityName] inManagedObjectStore:managedObjectStore];
    
    [entityMapping addAttributeMappingsFromArray:@[CCListMetaAttributes.identifier]];
    return entityMapping;
}

@end
