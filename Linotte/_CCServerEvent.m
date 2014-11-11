// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CCServerEvent.m instead.

#import "_CCServerEvent.h"

const struct CCServerEventAttributes CCServerEventAttributes = {
	.date = @"date",
	.event = @"event",
	.objectIdentifier = @"objectIdentifier",
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

@dynamic objectIdentifier;

@dynamic list;

@end

