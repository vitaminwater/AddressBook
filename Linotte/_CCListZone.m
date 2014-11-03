// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CCListZone.m instead.

#import "_CCListZone.h"

const struct CCListZoneAttributes CCListZoneAttributes = {
	.firstFetch = @"firstFetch",
	.geohash = @"geohash",
	.lastAddressFirstFetchDate = @"lastAddressFirstFetchDate",
	.lastEventId = @"lastEventId",
	.lastRefresh = @"lastRefresh",
	.latitude = @"latitude",
	.longitude = @"longitude",
	.nAddresses = @"nAddresses",
};

const struct CCListZoneRelationships CCListZoneRelationships = {
	.list = @"list",
};

@implementation CCListZoneID
@end

@implementation _CCListZone

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CCListZone" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CCListZone";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CCListZone" inManagedObjectContext:moc_];
}

- (CCListZoneID*)objectID {
	return (CCListZoneID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"firstFetchValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"firstFetch"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"lastEventIdValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"lastEventId"];
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
	if ([key isEqualToString:@"nAddressesValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"nAddresses"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic firstFetch;

- (BOOL)firstFetchValue {
	NSNumber *result = [self firstFetch];
	return [result boolValue];
}

- (void)setFirstFetchValue:(BOOL)value_ {
	[self setFirstFetch:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveFirstFetchValue {
	NSNumber *result = [self primitiveFirstFetch];
	return [result boolValue];
}

- (void)setPrimitiveFirstFetchValue:(BOOL)value_ {
	[self setPrimitiveFirstFetch:[NSNumber numberWithBool:value_]];
}

@dynamic geohash;

@dynamic lastAddressFirstFetchDate;

@dynamic lastEventId;

- (int64_t)lastEventIdValue {
	NSNumber *result = [self lastEventId];
	return [result longLongValue];
}

- (void)setLastEventIdValue:(int64_t)value_ {
	[self setLastEventId:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveLastEventIdValue {
	NSNumber *result = [self primitiveLastEventId];
	return [result longLongValue];
}

- (void)setPrimitiveLastEventIdValue:(int64_t)value_ {
	[self setPrimitiveLastEventId:[NSNumber numberWithLongLong:value_]];
}

@dynamic lastRefresh;

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

@dynamic nAddresses;

- (int16_t)nAddressesValue {
	NSNumber *result = [self nAddresses];
	return [result shortValue];
}

- (void)setNAddressesValue:(int16_t)value_ {
	[self setNAddresses:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveNAddressesValue {
	NSNumber *result = [self primitiveNAddresses];
	return [result shortValue];
}

- (void)setPrimitiveNAddressesValue:(int16_t)value_ {
	[self setPrimitiveNAddresses:[NSNumber numberWithShort:value_]];
}

@dynamic list;

@end

