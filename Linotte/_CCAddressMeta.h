// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CCAddressMeta.h instead.

#import <CoreData/CoreData.h>

extern const struct CCAddressMetaAttributes {
	__unsafe_unretained NSString *identifier;
	__unsafe_unretained NSString *internal_name;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *value;
} CCAddressMetaAttributes;

extern const struct CCAddressMetaRelationships {
	__unsafe_unretained NSString *address;
} CCAddressMetaRelationships;

@class CCAddress;

@interface CCAddressMetaID : NSManagedObjectID {}
@end

@interface _CCAddressMeta : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) CCAddressMetaID* objectID;

@property (nonatomic, strong) NSString* identifier;

//- (BOOL)validateIdentifier:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* internal_name;

//- (BOOL)validateInternal_name:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* value;

//- (BOOL)validateValue:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) CCAddress *address;

//- (BOOL)validateAddress:(id*)value_ error:(NSError**)error_;

@end

@interface _CCAddressMeta (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveIdentifier;
- (void)setPrimitiveIdentifier:(NSString*)value;

- (NSString*)primitiveInternal_name;
- (void)setPrimitiveInternal_name:(NSString*)value;

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (NSString*)primitiveValue;
- (void)setPrimitiveValue:(NSString*)value;

- (CCAddress*)primitiveAddress;
- (void)setPrimitiveAddress:(CCAddress*)value;

@end
