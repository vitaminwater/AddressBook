// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CCAuthMethod.m instead.

#import "_CCAuthMethod.h"

const struct CCAuthMethodAttributes CCAuthMethodAttributes = {
	.infos = @"infos",
	.signup = @"signup",
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

	if ([key isEqualToString:@"signupValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"signup"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic infos;

@dynamic signup;

- (BOOL)signupValue {
	NSNumber *result = [self signup];
	return [result boolValue];
}

- (void)setSignupValue:(BOOL)value_ {
	[self setSignup:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveSignupValue {
	NSNumber *result = [self primitiveSignup];
	return [result boolValue];
}

- (void)setPrimitiveSignupValue:(BOOL)value_ {
	[self setPrimitiveSignup:[NSNumber numberWithBool:value_]];
}

@dynamic type;

@end

