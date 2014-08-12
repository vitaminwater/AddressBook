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
	.notify = @"notify",
	.sent = @"sent",
};

const struct CCAddressRelationships CCAddressRelationships = {
	.categories = @"categories",
};

const struct CCAddressFetchedProperties CCAddressFetchedProperties = {
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
	if ([key isEqualToString:@"sentValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"sent"];
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





@dynamic categories;

	
- (NSMutableSet*)categoriesSet {
	[self willAccessValueForKey:@"categories"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"categories"];
  
	[self didAccessValueForKey:@"categories"];
	return result;
}
	






@end
