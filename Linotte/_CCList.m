// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CCList.m instead.

#import "_CCList.h"

const struct CCListAttributes CCListAttributes = {
	.expanded = @"expanded",
	.icon = @"icon",
	.identifier = @"identifier",
	.name = @"name",
	.notify = @"notify",
	.provider = @"provider",
	.providerId = @"providerId",
	.sent = @"sent",
};

const struct CCListRelationships CCListRelationships = {
	.addresses = @"addresses",
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

	if ([key isEqualToString:@"expandedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"expanded"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"notifyValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"notify"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"sentValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"sent"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic expanded;

- (BOOL)expandedValue {
	NSNumber *result = [self expanded];
	return [result boolValue];
}

- (void)setExpandedValue:(BOOL)value_ {
	[self setExpanded:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveExpandedValue {
	NSNumber *result = [self primitiveExpanded];
	return [result boolValue];
}

- (void)setPrimitiveExpandedValue:(BOOL)value_ {
	[self setPrimitiveExpanded:[NSNumber numberWithBool:value_]];
}

@dynamic icon;

@dynamic identifier;

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

@dynamic provider;

@dynamic providerId;

@dynamic sent;

- (BOOL)sentValue {
	NSNumber *result = [self sent];
	return [result boolValue];
}

- (void)setSentValue:(BOOL)value_ {
	[self setSent:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveSentValue {
	NSNumber *result = [self primitiveSent];
	return [result boolValue];
}

- (void)setPrimitiveSentValue:(BOOL)value_ {
	[self setPrimitiveSent:[NSNumber numberWithBool:value_]];
}

@dynamic addresses;

- (NSMutableSet*)addressesSet {
	[self willAccessValueForKey:@"addresses"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"addresses"];

	[self didAccessValueForKey:@"addresses"];
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

