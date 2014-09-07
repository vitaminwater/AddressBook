// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CCAddressMeta.m instead.

#import "_CCAddressMeta.h"

const struct CCAddressMetaAttributes CCAddressMetaAttributes = {
	.identifier = @"identifier",
	.internal_name = @"internal_name",
	.name = @"name",
	.value = @"value",
};

const struct CCAddressMetaRelationships CCAddressMetaRelationships = {
	.address = @"address",
};

const struct CCAddressMetaFetchedProperties CCAddressMetaFetchedProperties = {
};

@implementation CCAddressMetaID
@end

@implementation _CCAddressMeta

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CCAddressMeta" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CCAddressMeta";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CCAddressMeta" inManagedObjectContext:moc_];
}

- (CCAddressMetaID*)objectID {
	return (CCAddressMetaID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic identifier;






@dynamic internal_name;






@dynamic name;






@dynamic value;






@dynamic address;

	






@end
