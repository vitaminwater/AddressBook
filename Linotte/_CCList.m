// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CCList.m instead.

#import "_CCList.h"

const struct CCListAttributes CCListAttributes = {
	.author = @"author",
	.authorIdentifier = @"authorIdentifier",
	.avgInactiveDays = @"avgInactiveDays",
	.icon = @"icon",
	.identifier = @"identifier",
	.isdefault = @"isdefault",
	.lastEventDate = @"lastEventDate",
	.lastOpened = @"lastOpened",
	.lastUpdate = @"lastUpdate",
	.lastZoneCleaningLatitude = @"lastZoneCleaningLatitude",
	.lastZoneCleaningLongitude = @"lastZoneCleaningLongitude",
	.lastZoneRefreshLatitude = @"lastZoneRefreshLatitude",
	.lastZoneRefreshLongitude = @"lastZoneRefreshLongitude",
	.lastZonesRefresh = @"lastZonesRefresh",
	.localIdentifier = @"localIdentifier",
	.name = @"name",
	.notify = @"notify",
	.owned = @"owned",
};

const struct CCListRelationships CCListRelationships = {
	.addressMetas = @"addressMetas",
	.addresses = @"addresses",
	.metas = @"metas",
	.serverEvents = @"serverEvents",
	.zones = @"zones",
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

	if ([key isEqualToString:@"avgInactiveDaysValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"avgInactiveDays"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isdefaultValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isdefault"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"lastZoneCleaningLatitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"lastZoneCleaningLatitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"lastZoneCleaningLongitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"lastZoneCleaningLongitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"lastZoneRefreshLatitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"lastZoneRefreshLatitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"lastZoneRefreshLongitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"lastZoneRefreshLongitude"];
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

@dynamic author;

@dynamic authorIdentifier;

@dynamic avgInactiveDays;

- (double)avgInactiveDaysValue {
	NSNumber *result = [self avgInactiveDays];
	return [result doubleValue];
}

- (void)setAvgInactiveDaysValue:(double)value_ {
	[self setAvgInactiveDays:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveAvgInactiveDaysValue {
	NSNumber *result = [self primitiveAvgInactiveDays];
	return [result doubleValue];
}

- (void)setPrimitiveAvgInactiveDaysValue:(double)value_ {
	[self setPrimitiveAvgInactiveDays:[NSNumber numberWithDouble:value_]];
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

@dynamic lastEventDate;

@dynamic lastOpened;

@dynamic lastUpdate;

@dynamic lastZoneCleaningLatitude;

- (double)lastZoneCleaningLatitudeValue {
	NSNumber *result = [self lastZoneCleaningLatitude];
	return [result doubleValue];
}

- (void)setLastZoneCleaningLatitudeValue:(double)value_ {
	[self setLastZoneCleaningLatitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveLastZoneCleaningLatitudeValue {
	NSNumber *result = [self primitiveLastZoneCleaningLatitude];
	return [result doubleValue];
}

- (void)setPrimitiveLastZoneCleaningLatitudeValue:(double)value_ {
	[self setPrimitiveLastZoneCleaningLatitude:[NSNumber numberWithDouble:value_]];
}

@dynamic lastZoneCleaningLongitude;

- (double)lastZoneCleaningLongitudeValue {
	NSNumber *result = [self lastZoneCleaningLongitude];
	return [result doubleValue];
}

- (void)setLastZoneCleaningLongitudeValue:(double)value_ {
	[self setLastZoneCleaningLongitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveLastZoneCleaningLongitudeValue {
	NSNumber *result = [self primitiveLastZoneCleaningLongitude];
	return [result doubleValue];
}

- (void)setPrimitiveLastZoneCleaningLongitudeValue:(double)value_ {
	[self setPrimitiveLastZoneCleaningLongitude:[NSNumber numberWithDouble:value_]];
}

@dynamic lastZoneRefreshLatitude;

- (double)lastZoneRefreshLatitudeValue {
	NSNumber *result = [self lastZoneRefreshLatitude];
	return [result doubleValue];
}

- (void)setLastZoneRefreshLatitudeValue:(double)value_ {
	[self setLastZoneRefreshLatitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveLastZoneRefreshLatitudeValue {
	NSNumber *result = [self primitiveLastZoneRefreshLatitude];
	return [result doubleValue];
}

- (void)setPrimitiveLastZoneRefreshLatitudeValue:(double)value_ {
	[self setPrimitiveLastZoneRefreshLatitude:[NSNumber numberWithDouble:value_]];
}

@dynamic lastZoneRefreshLongitude;

- (double)lastZoneRefreshLongitudeValue {
	NSNumber *result = [self lastZoneRefreshLongitude];
	return [result doubleValue];
}

- (void)setLastZoneRefreshLongitudeValue:(double)value_ {
	[self setLastZoneRefreshLongitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveLastZoneRefreshLongitudeValue {
	NSNumber *result = [self primitiveLastZoneRefreshLongitude];
	return [result doubleValue];
}

- (void)setPrimitiveLastZoneRefreshLongitudeValue:(double)value_ {
	[self setPrimitiveLastZoneRefreshLongitude:[NSNumber numberWithDouble:value_]];
}

@dynamic lastZonesRefresh;

@dynamic localIdentifier;

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

@dynamic addressMetas;

- (NSMutableSet*)addressMetasSet {
	[self willAccessValueForKey:@"addressMetas"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"addressMetas"];

	[self didAccessValueForKey:@"addressMetas"];
	return result;
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

@dynamic serverEvents;

- (NSMutableSet*)serverEventsSet {
	[self willAccessValueForKey:@"serverEvents"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"serverEvents"];

	[self didAccessValueForKey:@"serverEvents"];
	return result;
}

@dynamic zones;

- (NSMutableSet*)zonesSet {
	[self willAccessValueForKey:@"zones"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"zones"];

	[self didAccessValueForKey:@"zones"];
	return result;
}

@end

