// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CCSocialAccount.m instead.

#import "_CCSocialAccount.h"

const struct CCSocialAccountAttributes CCSocialAccountAttributes = {
	.authTokenKey = @"authTokenKey",
	.expirationDate = @"expirationDate",
	.identifier = @"identifier",
	.mediaIdentifier = @"mediaIdentifier",
	.refreshTokenKey = @"refreshTokenKey",
	.socialIdentifier = @"socialIdentifier",
};

@implementation CCSocialAccountID
@end

@implementation _CCSocialAccount

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CCSocialAccount" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CCSocialAccount";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CCSocialAccount" inManagedObjectContext:moc_];
}

- (CCSocialAccountID*)objectID {
	return (CCSocialAccountID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic authTokenKey;

@dynamic expirationDate;

@dynamic identifier;

@dynamic mediaIdentifier;

@dynamic refreshTokenKey;

@dynamic socialIdentifier;

@end

