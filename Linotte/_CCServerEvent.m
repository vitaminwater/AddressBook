// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CCServerEvent.m instead.

#import "_CCServerEvent.h"

const struct CCServerEventAttributes CCServerEventAttributes = {
	.event = @"event",
	.id = @"id",
	.object_identifier = @"object_identifier",
};

const struct CCServerEventRelationships CCServerEventRelationships = {
	.list = @"list",
};

@implementation CCServerEventID
@end

@implementation _CCServerEvent

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CCServerEvent" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CCServerEvent";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CCServerEvent" inManagedObjectContext:moc_];
}

- (CCServerEventID*)objectID {
	return (CCServerEventID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"eventValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"event"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"idValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"id"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic event;

- (int16_t)eventValue {
	NSNumber *result = [self event];
	return [result shortValue];
}

- (void)setEventValue:(int16_t)value_ {
	[self setEvent:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveEventValue {
	NSNumber *result = [self primitiveEvent];
	return [result shortValue];
}

- (void)setPrimitiveEventValue:(int16_t)value_ {
	[self setPrimitiveEvent:[NSNumber numberWithShort:value_]];
}

@dynamic id;

- (int64_t)idValue {
	NSNumber *result = [self id];
	return [result longLongValue];
}

- (void)setIdValue:(int64_t)value_ {
	[self setId:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveIdValue {
	NSNumber *result = [self primitiveId];
	return [result longLongValue];
}

- (void)setPrimitiveIdValue:(int64_t)value_ {
	[self setPrimitiveId:[NSNumber numberWithLongLong:value_]];
}

@dynamic object_identifier;

@dynamic list;

@end

