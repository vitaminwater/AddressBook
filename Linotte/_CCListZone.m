// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CCListZone.m instead.

#import "_CCListZone.h"

const struct CCListZoneAttributes CCListZoneAttributes = {
	.firstFetch = @"firstFetch",
	.geohash = @"geohash",
	.lastAddressFirstFetchDate = @"lastAddressFirstFetchDate",
	.lastEventDate = @"lastEventDate",
	.lastUpdate = @"lastUpdate",
	.latitude = @"latitude",
	.longNextRefreshDate = @"longNextRefreshDate",
	.longitude = @"longitude",
	.nAddresses = @"nAddresses",
	.needsMerge = @"needsMerge",
	.readyToMerge = @"readyToMerge",
	.shortNextRefreshDate = @"shortNextRefreshDate",
	.waitingTime = @"waitingTime",
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
	if ([key isEqualToString:@"readyToMergeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"readyToMerge"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"waitingTimeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"waitingTime"];
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

@dynamic lastEventDate;

@dynamic lastUpdate;

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

@dynamic longNextRefreshDate;

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

@dynamic needsMerge;

@dynamic readyToMerge;

- (BOOL)readyToMergeValue {
	NSNumber *result = [self readyToMerge];
	return [result boolValue];
}

- (void)setReadyToMergeValue:(BOOL)value_ {
	[self setReadyToMerge:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveReadyToMergeValue {
	NSNumber *result = [self primitiveReadyToMerge];
	return [result boolValue];
}

- (void)setPrimitiveReadyToMergeValue:(BOOL)value_ {
	[self setPrimitiveReadyToMerge:[NSNumber numberWithBool:value_]];
}

@dynamic shortNextRefreshDate;

@dynamic waitingTime;

- (int32_t)waitingTimeValue {
	NSNumber *result = [self waitingTime];
	return [result intValue];
}

- (void)setWaitingTimeValue:(int32_t)value_ {
	[self setWaitingTime:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveWaitingTimeValue {
	NSNumber *result = [self primitiveWaitingTime];
	return [result intValue];
}

- (void)setPrimitiveWaitingTimeValue:(int32_t)value_ {
	[self setPrimitiveWaitingTime:[NSNumber numberWithInt:value_]];
}

@dynamic list;

@end

