// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CCListAddressLink.m instead.

#import "_CCListAddressLink.h"

const struct CCListAddressLinkRelationships CCListAddressLinkRelationships = {
	.address = @"address",
	.list = @"list",
	.metas = @"metas",
};

@implementation CCListAddressLinkID
@end

@implementation _CCListAddressLink

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CCListAddressLink" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CCListAddressLink";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CCListAddressLink" inManagedObjectContext:moc_];
}

- (CCListAddressLinkID*)objectID {
	return (CCListAddressLinkID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic address;

@dynamic list;

@dynamic metas;

@end

