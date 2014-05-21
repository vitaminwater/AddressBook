// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CCCategories.m instead.

#import "_CCCategories.h"

const struct CCCategoriesAttributes CCCategoriesAttributes = {
	.identifier = @"identifier",
	.name = @"name",
};

const struct CCCategoriesRelationships CCCategoriesRelationships = {
	.address = @"address",
};

const struct CCCategoriesFetchedProperties CCCategoriesFetchedProperties = {
};

@implementation CCCategoriesID
@end

@implementation _CCCategories

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CCCategories" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CCCategories";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CCCategories" inManagedObjectContext:moc_];
}

- (CCCategoriesID*)objectID {
	return (CCCategoriesID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic identifier;






@dynamic name;






@dynamic address;

	






@end
