// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CCSocialAccount.h instead.

#import <CoreData/CoreData.h>

extern const struct CCSocialAccountAttributes {
	__unsafe_unretained NSString *authTokenKey;
	__unsafe_unretained NSString *expirationDate;
	__unsafe_unretained NSString *identifier;
	__unsafe_unretained NSString *mediaIdentifier;
	__unsafe_unretained NSString *refreshTokenKey;
	__unsafe_unretained NSString *socialIdentifier;
} CCSocialAccountAttributes;

@interface CCSocialAccountID : NSManagedObjectID {}
@end

@interface _CCSocialAccount : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) CCSocialAccountID* objectID;

@property (nonatomic, strong) NSString* authTokenKey;

//- (BOOL)validateAuthTokenKey:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* expirationDate;

//- (BOOL)validateExpirationDate:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* identifier;

//- (BOOL)validateIdentifier:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* mediaIdentifier;

//- (BOOL)validateMediaIdentifier:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* refreshTokenKey;

//- (BOOL)validateRefreshTokenKey:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* socialIdentifier;

//- (BOOL)validateSocialIdentifier:(id*)value_ error:(NSError**)error_;

@end

@interface _CCSocialAccount (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveAuthTokenKey;
- (void)setPrimitiveAuthTokenKey:(NSString*)value;

- (NSDate*)primitiveExpirationDate;
- (void)setPrimitiveExpirationDate:(NSDate*)value;

- (NSString*)primitiveIdentifier;
- (void)setPrimitiveIdentifier:(NSString*)value;

- (NSString*)primitiveMediaIdentifier;
- (void)setPrimitiveMediaIdentifier:(NSString*)value;

- (NSString*)primitiveRefreshTokenKey;
- (void)setPrimitiveRefreshTokenKey:(NSString*)value;

- (NSString*)primitiveSocialIdentifier;
- (void)setPrimitiveSocialIdentifier:(NSString*)value;

@end
