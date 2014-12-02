// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CCAddressMeta.h instead.

#import <CoreData/CoreData.h>

extern const struct CCAddressMetaAttributes {
	__unsafe_unretained NSString *action;
	__unsafe_unretained NSString *content;
	__unsafe_unretained NSString *identifier;
	__unsafe_unretained NSString *uid;
} CCAddressMetaAttributes;

extern const struct CCAddressMetaRelationships {
	__unsafe_unretained NSString *address;
	__unsafe_unretained NSString *list;
} CCAddressMetaRelationships;

@class CCAddress;
@class CCList;

@class NSObject;

@interface CCAddressMetaID : NSManagedObjectID {}
@end

@interface _CCAddressMeta : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) CCAddressMetaID* objectID;

@property (nonatomic, strong) NSString* action;

//- (BOOL)validateAction:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) id content;

//- (BOOL)validateContent:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* identifier;

//- (BOOL)validateIdentifier:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* uid;

//- (BOOL)validateUid:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) CCAddress *address;

//- (BOOL)validateAddress:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) CCList *list;

//- (BOOL)validateList:(id*)value_ error:(NSError**)error_;

@end

@interface _CCAddressMeta (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveAction;
- (void)setPrimitiveAction:(NSString*)value;

- (id)primitiveContent;
- (void)setPrimitiveContent:(id)value;

- (NSString*)primitiveIdentifier;
- (void)setPrimitiveIdentifier:(NSString*)value;

- (NSString*)primitiveUid;
- (void)setPrimitiveUid:(NSString*)value;

- (CCAddress*)primitiveAddress;
- (void)setPrimitiveAddress:(CCAddress*)value;

- (CCList*)primitiveList;
- (void)setPrimitiveList:(CCList*)value;

@end
