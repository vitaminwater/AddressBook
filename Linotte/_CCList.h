// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CCList.h instead.

#import <CoreData/CoreData.h>

extern const struct CCListAttributes {
	__unsafe_unretained NSString *expanded;
	__unsafe_unretained NSString *icon;
	__unsafe_unretained NSString *identifier;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *notify;
	__unsafe_unretained NSString *provider;
	__unsafe_unretained NSString *providerId;
} CCListAttributes;

extern const struct CCListRelationships {
	__unsafe_unretained NSString *addressMetas;
	__unsafe_unretained NSString *addresses;
	__unsafe_unretained NSString *events;
	__unsafe_unretained NSString *metas;
} CCListRelationships;

@class CCAddressMeta;
@class CCAddress;
@class CCNetworkEvent;
@class CCListMeta;

@interface CCListID : NSManagedObjectID {}
@end

@interface _CCList : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) CCListID* objectID;

@property (nonatomic, strong) NSNumber* expanded;

@property (atomic) BOOL expandedValue;
- (BOOL)expandedValue;
- (void)setExpandedValue:(BOOL)value_;

//- (BOOL)validateExpanded:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* icon;

//- (BOOL)validateIcon:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* identifier;

//- (BOOL)validateIdentifier:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* notify;

@property (atomic) BOOL notifyValue;
- (BOOL)notifyValue;
- (void)setNotifyValue:(BOOL)value_;

//- (BOOL)validateNotify:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* provider;

//- (BOOL)validateProvider:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* providerId;

//- (BOOL)validateProviderId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) CCAddressMeta *addressMetas;

//- (BOOL)validateAddressMetas:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *addresses;

- (NSMutableSet*)addressesSet;

@property (nonatomic, strong) NSSet *events;

- (NSMutableSet*)eventsSet;

@property (nonatomic, strong) NSSet *metas;

- (NSMutableSet*)metasSet;

@end

@interface _CCList (AddressesCoreDataGeneratedAccessors)
- (void)addAddresses:(NSSet*)value_;
- (void)removeAddresses:(NSSet*)value_;
- (void)addAddressesObject:(CCAddress*)value_;
- (void)removeAddressesObject:(CCAddress*)value_;

@end

@interface _CCList (EventsCoreDataGeneratedAccessors)
- (void)addEvents:(NSSet*)value_;
- (void)removeEvents:(NSSet*)value_;
- (void)addEventsObject:(CCNetworkEvent*)value_;
- (void)removeEventsObject:(CCNetworkEvent*)value_;

@end

@interface _CCList (MetasCoreDataGeneratedAccessors)
- (void)addMetas:(NSSet*)value_;
- (void)removeMetas:(NSSet*)value_;
- (void)addMetasObject:(CCListMeta*)value_;
- (void)removeMetasObject:(CCListMeta*)value_;

@end

@interface _CCList (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveExpanded;
- (void)setPrimitiveExpanded:(NSNumber*)value;

- (BOOL)primitiveExpandedValue;
- (void)setPrimitiveExpandedValue:(BOOL)value_;

- (NSString*)primitiveIcon;
- (void)setPrimitiveIcon:(NSString*)value;

- (NSString*)primitiveIdentifier;
- (void)setPrimitiveIdentifier:(NSString*)value;

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (NSNumber*)primitiveNotify;
- (void)setPrimitiveNotify:(NSNumber*)value;

- (BOOL)primitiveNotifyValue;
- (void)setPrimitiveNotifyValue:(BOOL)value_;

- (NSString*)primitiveProvider;
- (void)setPrimitiveProvider:(NSString*)value;

- (NSString*)primitiveProviderId;
- (void)setPrimitiveProviderId:(NSString*)value;

- (CCAddressMeta*)primitiveAddressMetas;
- (void)setPrimitiveAddressMetas:(CCAddressMeta*)value;

- (NSMutableSet*)primitiveAddresses;
- (void)setPrimitiveAddresses:(NSMutableSet*)value;

- (NSMutableSet*)primitiveEvents;
- (void)setPrimitiveEvents:(NSMutableSet*)value;

- (NSMutableSet*)primitiveMetas;
- (void)setPrimitiveMetas:(NSMutableSet*)value;

@end
