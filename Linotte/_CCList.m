// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CCList.m instead.

#import "_CCList.h"

const struct CCListAttributes CCListAttributes = {
	.icon = @"icon",
	.identifier = @"identifier",
	.isdefault = @"isdefault",
	.name = @"name",
	.notify = @"notify",
	.owned = @"owned",
	.provider = @"provider",
	.providerId = @"providerId",
};

const struct CCListRelationships CCListRelationships = {
	.addressMetas = @"addressMetas",
	.addresses = @"addresses",
	.events = @"events",
	.metas = @"metas",
};

@implementation CCListID
@end

@implementation _CCList

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CCList" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CCList";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CCList" inManagedObjectContext:moc_];
}

- (CCListID*)objectID {
	return (CCListID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"isdefaultValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isdefault"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"notifyValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"notify"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"ownedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"owned"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic icon;

@dynamic identifier;

@dynamic isdefault;

- (BOOL)isdefaultValue {
	NSNumber *result = [self isdefault];
	return [result boolValue];
}

- (void)setIsdefaultValue:(BOOL)value_ {
	[self setIsdefault:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsdefaultValue {
	NSNumber *result = [self primitiveIsdefault];
	return [result boolValue];
}

- (void)setPrimitiveIsdefaultValue:(BOOL)value_ {
	[self setPrimitiveIsdefault:[NSNumber numberWithBool:value_]];
}

@dynamic name;

@dynamic notify;

- (BOOL)notifyValue {
	NSNumber *result = [self notify];
	return [result boolValue];
}

- (void)setNotifyValue:(BOOL)value_ {
	[self setNotify:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveNotifyValue {
	NSNumber *result = [self primitiveNotify];
	return [result boolValue];
}

- (void)setPrimitiveNotifyValue:(BOOL)value_ {
	[self setPrimitiveNotify:[NSNumber numberWithBool:value_]];
}

@dynamic owned;

- (BOOL)ownedValue {
	NSNumber *result = [self owned];
	return [result boolValue];
}

- (void)setOwnedValue:(BOOL)value_ {
	[self setOwned:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveOwnedValue {
	NSNumber *result = [self primitiveOwned];
	return [result boolValue];
}

- (void)setPrimitiveOwnedValue:(BOOL)value_ {
	[self setPrimitiveOwned:[NSNumber numberWithBool:value_]];
}

@dynamic provider;

@dynamic providerId;

@dynamic addressMetas;

@dynamic addresses;

- (NSMutableSet*)addressesSet {
	[self willAccessValueForKey:@"addresses"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"addresses"];

	[self didAccessValueForKey:@"addresses"];
	return result;
}

@dynamic events;

- (NSMutableSet*)eventsSet {
	[self willAccessValueForKey:@"events"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"events"];

	[self didAccessValueForKey:@"events"];
	return result;
}

@dynamic metas;

- (NSMutableSet*)metasSet {
	[self willAccessValueForKey:@"metas"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"metas"];

	[self didAccessValueForKey:@"metas"];
	return result;
}

@end

