// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CCServerEvent.m instead.

#import "_CCServerEvent.h"

const struct CCServerEventAttributes CCServerEventAttributes = {
	.date = @"date",
	.event = @"event",
	.eventId = @"eventId",
	.objectIdentifier = @"objectIdentifier",
	.objectIdentifier2 = @"objectIdentifier2",
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
	if ([key isEqualToString:@"eventIdValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"eventId"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic date;

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

@dynamic eventId;

- (int64_t)eventIdValue {
	NSNumber *result = [self eventId];
	return [result longLongValue];
}

- (void)setEventIdValue:(int64_t)value_ {
	[self setEventId:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveEventIdValue {
	NSNumber *result = [self primitiveEventId];
	return [result longLongValue];
}

- (void)setPrimitiveEventIdValue:(int64_t)value_ {
	[self setPrimitiveEventId:[NSNumber numberWithLongLong:value_]];
}

@dynamic objectIdentifier;

@dynamic objectIdentifier2;

@dynamic list;

@end

