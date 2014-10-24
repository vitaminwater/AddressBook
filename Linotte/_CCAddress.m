// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CCAddress.m instead.

#import "_CCAddress.h"

const struct CCAddressAttributes CCAddressAttributes = {
	.address = @"address",
	.date = @"date",
	.geohash = @"geohash",
	.identifier = @"identifier",
	.lastnotif = @"lastnotif",
	.latitude = @"latitude",
	.longitude = @"longitude",
	.name = @"name",
	.note = @"note",
	.notificationId = @"notificationId",
	.notify = @"notify",
	.provider = @"provider",
	.providerId = @"providerId",
};

const struct CCAddressRelationships CCAddressRelationships = {
	.categories = @"categories",
	.events = @"events",
	.lists = @"lists",
	.metas = @"metas",
};

@implementation CCAddressID
@end

@implementation _CCAddress

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CCAddress" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CCAddress";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CCAddress" inManagedObjectContext:moc_];
}

- (CCAddressID*)objectID {
	return (CCAddressID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"latitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"latitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"longitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"longitude"];
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

@dynamic address;

@dynamic date;

@dynamic geohash;

@dynamic identifier;

@dynamic lastnotif;

@dynamic latitude;

- (double)latitudeValue {
	NSNumber *result = [self latitude];
	return [result doubleValue];
}

- (void)setLatitudeValue:(double)value_ {
	[self setLatitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveLatitudeValue {
	NSNumber *result = [self primitiveLatitude];
	return [result doubleValue];
}

- (void)setPrimitiveLatitudeValue:(double)value_ {
	[self setPrimitiveLatitude:[NSNumber numberWithDouble:value_]];
}

@dynamic longitude;

- (double)longitudeValue {
	NSNumber *result = [self longitude];
	return [result doubleValue];
}

- (void)setLongitudeValue:(double)value_ {
	[self setLongitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveLongitudeValue {
	NSNumber *result = [self primitiveLongitude];
	return [result doubleValue];
}

- (void)setPrimitiveLongitudeValue:(double)value_ {
	[self setPrimitiveLongitude:[NSNumber numberWithDouble:value_]];
}

@dynamic name;

@dynamic note;

@dynamic notificationId;

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

@dynamic categories;

- (NSMutableSet*)categoriesSet {
	[self willAccessValueForKey:@"categories"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"categories"];

	[self didAccessValueForKey:@"categories"];
	return result;
}

@dynamic events;

- (NSMutableSet*)eventsSet {
	[self willAccessValueForKey:@"events"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"events"];

	[self didAccessValueForKey:@"events"];
	return result;
}

@dynamic lists;

- (NSMutableSet*)listsSet {
	[self willAccessValueForKey:@"lists"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"lists"];

	[self didAccessValueForKey:@"lists"];
	return result;
}

@dynamic metas;

@end

