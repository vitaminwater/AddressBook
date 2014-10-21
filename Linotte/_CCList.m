// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CCList.m instead.

#import "_CCList.h"

const struct CCListAttributes CCListAttributes = {
	.expanded = @"expanded",
	.icon = @"icon",
	.identifier = @"identifier",
	.last_update = @"last_update",
	.last_update_latitude = @"last_update_latitude",
	.last_update_longitude = @"last_update_longitude",
	.name = @"name",
	.notify = @"notify",
	.provider = @"provider",
	.providerId = @"providerId",
};

const struct CCListRelationships CCListRelationships = {
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

	if ([key isEqualToString:@"expandedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"expanded"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"last_update_latitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"last_update_latitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"last_update_longitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"last_update_longitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"notifyValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"notify"];
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

@dynamic last_update;

@dynamic last_update_latitude;

- (double)last_update_latitudeValue {
	NSNumber *result = [self last_update_latitude];
	return [result doubleValue];
}

- (void)setLast_update_latitudeValue:(double)value_ {
	[self setLast_update_latitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveLast_update_latitudeValue {
	NSNumber *result = [self primitiveLast_update_latitude];
	return [result doubleValue];
}

- (void)setPrimitiveLast_update_latitudeValue:(double)value_ {
	[self setPrimitiveLast_update_latitude:[NSNumber numberWithDouble:value_]];
}

@dynamic last_update_longitude;

- (double)last_update_longitudeValue {
	NSNumber *result = [self last_update_longitude];
	return [result doubleValue];
}

- (void)setLast_update_longitudeValue:(double)value_ {
	[self setLast_update_longitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveLast_update_longitudeValue {
	NSNumber *result = [self primitiveLast_update_longitude];
	return [result doubleValue];
}

- (void)setPrimitiveLast_update_longitudeValue:(double)value_ {
	[self setPrimitiveLast_update_longitude:[NSNumber numberWithDouble:value_]];
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

@dynamic provider;

@dynamic providerId;

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

