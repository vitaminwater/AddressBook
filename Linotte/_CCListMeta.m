// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CCListMeta.m instead.

#import "_CCListMeta.h"

const struct CCListMetaAttributes CCListMetaAttributes = {
	.action = @"action",
	.content = @"content",
	.identifier = @"identifier",
	.uid = @"uid",
};

const struct CCListMetaRelationships CCListMetaRelationships = {
	.list = @"list",
};

@implementation CCListMetaID
@end

@implementation _CCListMeta

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CCListMeta" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CCListMeta";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CCListMeta" inManagedObjectContext:moc_];
}

- (CCListMetaID*)objectID {
	return (CCListMetaID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic action;

@dynamic content;

@dynamic identifier;

@dynamic uid;

@dynamic list;

@end

