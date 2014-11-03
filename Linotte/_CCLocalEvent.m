// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CCLocalEvent.m instead.

#import "_CCLocalEvent.h"

const struct CCLocalEventAttributes CCLocalEventAttributes = {
	.date = @"date",
	.event = @"event",
	.identifier = @"identifier",
};

const struct CCLocalEventRelationships CCLocalEventRelationships = {
	.address = @"address",
	.list = @"list",
};

@implementation CCLocalEventID
@end

@implementation _CCLocalEvent

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CCLocalEvent" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CCLocalEvent";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CCLocalEvent" inManagedObjectContext:moc_];
}

- (CCLocalEventID*)objectID {
	return (CCLocalEventID*)[super objectID];
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

@dynamic identifier;

@dynamic address;

@dynamic list;

@end

