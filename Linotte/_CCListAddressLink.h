// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CCListAddressLink.h instead.

#import <CoreData/CoreData.h>

extern const struct CCListAddressLinkRelationships {
	__unsafe_unretained NSString *address;
	__unsafe_unretained NSString *list;
	__unsafe_unretained NSString *metas;
} CCListAddressLinkRelationships;

@class CCAddress;
@class CCList;
@class CCAddressMeta;

@interface CCListAddressLinkID : NSManagedObjectID {}
@end

@interface _CCListAddressLink : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) CCListAddressLinkID* objectID;

@property (nonatomic, strong) CCAddress *address;

//- (BOOL)validateAddress:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) CCList *list;

//- (BOOL)validateList:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) CCAddressMeta *metas;

//- (BOOL)validateMetas:(id*)value_ error:(NSError**)error_;

@end

@interface _CCListAddressLink (CoreDataGeneratedPrimitiveAccessors)

- (CCAddress*)primitiveAddress;
- (void)setPrimitiveAddress:(CCAddress*)value;

- (CCList*)primitiveList;
- (void)setPrimitiveList:(CCList*)value;

- (CCAddressMeta*)primitiveMetas;
- (void)setPrimitiveMetas:(CCAddressMeta*)value;

@end
