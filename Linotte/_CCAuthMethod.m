// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CCAuthMethod.m instead.

#import "_CCAuthMethod.h"

const struct CCAuthMethodAttributes CCAuthMethodAttributes = {
	.identifier = @"identifier",
	.infos = @"infos",
	.sent = @"sent",
	.type = @"type",
};

@implementation CCAuthMethodID
@end

@implementation _CCAuthMethod

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CCAuthMethod" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CCAuthMethod";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CCAuthMethod" inManagedObjectContext:moc_];
}

- (CCAuthMethodID*)objectID {
	return (CCAuthMethodID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"sentValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"sent"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic identifier;

@dynamic infos;

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

@dynamic type;

@end

