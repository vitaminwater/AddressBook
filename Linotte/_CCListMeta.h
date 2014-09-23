// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CCListMeta.h instead.

#import <CoreData/CoreData.h>

extern const struct CCListMetaAttributes {
	__unsafe_unretained NSString *identifier;
	__unsafe_unretained NSString *internal_name;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *value;
} CCListMetaAttributes;

extern const struct CCListMetaRelationships {
	__unsafe_unretained NSString *list;
} CCListMetaRelationships;

@class CCList;

@interface CCListMetaID : NSManagedObjectID {}
@end

@interface _CCListMeta : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) CCListMetaID* objectID;

@property (nonatomic, strong) NSString* identifier;

//- (BOOL)validateIdentifier:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* internal_name;

//- (BOOL)validateInternal_name:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* value;

//- (BOOL)validateValue:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) CCList *list;

//- (BOOL)validateList:(id*)value_ error:(NSError**)error_;

@end

@interface _CCListMeta (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveIdentifier;
- (void)setPrimitiveIdentifier:(NSString*)value;

- (NSString*)primitiveInternal_name;
- (void)setPrimitiveInternal_name:(NSString*)value;

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (NSString*)primitiveValue;
- (void)setPrimitiveValue:(NSString*)value;

- (CCList*)primitiveList;
- (void)setPrimitiveList:(CCList*)value;

@end
