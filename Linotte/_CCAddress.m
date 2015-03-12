// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CCAddress.m instead.

#import "_CCAddress.h"

const struct CCAddressAttributes CCAddressAttributes = {
	.address = @"address",
	.geohash = @"geohash",
	.identifier = @"identifier",
	.isAuthor = @"isAuthor",
	.isNew = @"isNew",
	.lastnotif = @"lastnotif",
	.latitude = @"latitude",
	.localIdentifier = @"localIdentifier",
	.longitude = @"longitude",
	.name = @"name",
	.note = @"note",
	.notify = @"notify",
	.provider = @"provider",
	.providerId = @"providerId",
};

const struct CCAddressRelationships CCAddressRelationships = {
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

	if ([key isEqualToString:@"isAuthorValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isAuthor"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isNewValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isNew"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
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

@dynamic geohash;

@dynamic identifier;

@dynamic isAuthor;

- (BOOL)isAuthorValue {
	NSNumber *result = [self isAuthor];
	return [result boolValue];
}

- (void)setIsAuthorValue:(BOOL)value_ {
	[self setIsAuthor:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsAuthorValue {
	NSNumber *result = [self primitiveIsAuthor];
	return [result boolValue];
}

- (void)setPrimitiveIsAuthorValue:(BOOL)value_ {
	[self setPrimitiveIsAuthor:[NSNumber numberWithBool:value_]];
}

@dynamic isNew;

- (BOOL)isNewValue {
	NSNumber *result = [self isNew];
	return [result boolValue];
}

- (void)setIsNewValue:(BOOL)value_ {
	[self setIsNew:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsNewValue {
	NSNumber *result = [self primitiveIsNew];
	return [result boolValue];
}

- (void)setPrimitiveIsNewValue:(BOOL)value_ {
	[self setPrimitiveIsNew:[NSNumber numberWithBool:value_]];
}

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

@dynamic localIdentifier;

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

@dynamic lists;

- (NSMutableSet*)listsSet {
	[self willAccessValueForKey:@"lists"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"lists"];

	[self didAccessValueForKey:@"lists"];
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

