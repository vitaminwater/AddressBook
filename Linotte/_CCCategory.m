// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CCCategory.m instead.

#import "_CCCategory.h"

const struct CCCategoryAttributes CCCategoryAttributes = {
	.identifier = @"identifier",
	.name = @"name",
};

const struct CCCategoryRelationships CCCategoryRelationships = {
	.address = @"address",
};

@implementation CCCategoryID
@end

@implementation _CCCategory

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CCCategory" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CCCategory";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CCCategory" inManagedObjectContext:moc_];
}

- (CCCategoryID*)objectID {
	return (CCCategoryID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic identifier;

@dynamic name;

@dynamic address;

@end

