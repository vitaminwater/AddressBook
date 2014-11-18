// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CCAddress.h instead.

#import <CoreData/CoreData.h>

extern const struct CCAddressAttributes {
	__unsafe_unretained NSString *address;
	__unsafe_unretained NSString *date;
	__unsafe_unretained NSString *geohash;
	__unsafe_unretained NSString *identifier;
	__unsafe_unretained NSString *lastnotif;
	__unsafe_unretained NSString *latitude;
	__unsafe_unretained NSString *localIdentifier;
	__unsafe_unretained NSString *longitude;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *note;
	__unsafe_unretained NSString *notify;
	__unsafe_unretained NSString *provider;
	__unsafe_unretained NSString *providerId;
} CCAddressAttributes;

extern const struct CCAddressRelationships {
	__unsafe_unretained NSString *categories;
	__unsafe_unretained NSString *lists;
	__unsafe_unretained NSString *metas;
} CCAddressRelationships;

@class CCCategory;
@class CCList;
@class CCAddressMeta;

@interface CCAddressID : NSManagedObjectID {}
@end

@interface _CCAddress : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) CCAddressID* objectID;

@property (nonatomic, strong) NSString* address;

//- (BOOL)validateAddress:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* date;

//- (BOOL)validateDate:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* geohash;

//- (BOOL)validateGeohash:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* identifier;

//- (BOOL)validateIdentifier:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* lastnotif;

//- (BOOL)validateLastnotif:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* latitude;

@property (atomic) double latitudeValue;
- (double)latitudeValue;
- (void)setLatitudeValue:(double)value_;

//- (BOOL)validateLatitude:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* localIdentifier;

//- (BOOL)validateLocalIdentifier:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* longitude;

@property (atomic) double longitudeValue;
- (double)longitudeValue;
- (void)setLongitudeValue:(double)value_;

//- (BOOL)validateLongitude:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* note;

//- (BOOL)validateNote:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* notify;

@property (atomic) BOOL notifyValue;
- (BOOL)notifyValue;
- (void)setNotifyValue:(BOOL)value_;

//- (BOOL)validateNotify:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* provider;

//- (BOOL)validateProvider:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* providerId;

//- (BOOL)validateProviderId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *categories;

- (NSMutableSet*)categoriesSet;

@property (nonatomic, strong) NSSet *lists;

- (NSMutableSet*)listsSet;

@property (nonatomic, strong) NSSet *metas;

- (NSMutableSet*)metasSet;

@end

@interface _CCAddress (CategoriesCoreDataGeneratedAccessors)
- (void)addCategories:(NSSet*)value_;
- (void)removeCategories:(NSSet*)value_;
- (void)addCategoriesObject:(CCCategory*)value_;
- (void)removeCategoriesObject:(CCCategory*)value_;

@end

@interface _CCAddress (ListsCoreDataGeneratedAccessors)
- (void)addLists:(NSSet*)value_;
- (void)removeLists:(NSSet*)value_;
- (void)addListsObject:(CCList*)value_;
- (void)removeListsObject:(CCList*)value_;

@end

@interface _CCAddress (MetasCoreDataGeneratedAccessors)
- (void)addMetas:(NSSet*)value_;
- (void)removeMetas:(NSSet*)value_;
- (void)addMetasObject:(CCAddressMeta*)value_;
- (void)removeMetasObject:(CCAddressMeta*)value_;

@end

@interface _CCAddress (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveAddress;
- (void)setPrimitiveAddress:(NSString*)value;

- (NSDate*)primitiveDate;
- (void)setPrimitiveDate:(NSDate*)value;

- (NSString*)primitiveGeohash;
- (void)setPrimitiveGeohash:(NSString*)value;

- (NSString*)primitiveIdentifier;
- (void)setPrimitiveIdentifier:(NSString*)value;

- (NSDate*)primitiveLastnotif;
- (void)setPrimitiveLastnotif:(NSDate*)value;

- (NSNumber*)primitiveLatitude;
- (void)setPrimitiveLatitude:(NSNumber*)value;

- (double)primitiveLatitudeValue;
- (void)setPrimitiveLatitudeValue:(double)value_;

- (NSString*)primitiveLocalIdentifier;
- (void)setPrimitiveLocalIdentifier:(NSString*)value;

- (NSNumber*)primitiveLongitude;
- (void)setPrimitiveLongitude:(NSNumber*)value;

- (double)primitiveLongitudeValue;
- (void)setPrimitiveLongitudeValue:(double)value_;

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (NSString*)primitiveNote;
- (void)setPrimitiveNote:(NSString*)value;

- (NSNumber*)primitiveNotify;
- (void)setPrimitiveNotify:(NSNumber*)value;

- (BOOL)primitiveNotifyValue;
- (void)setPrimitiveNotifyValue:(BOOL)value_;

- (NSString*)primitiveProvider;
- (void)setPrimitiveProvider:(NSString*)value;

- (NSString*)primitiveProviderId;
- (void)setPrimitiveProviderId:(NSString*)value;

- (NSMutableSet*)primitiveCategories;
- (void)setPrimitiveCategories:(NSMutableSet*)value;

- (NSMutableSet*)primitiveLists;
- (void)setPrimitiveLists:(NSMutableSet*)value;

- (NSMutableSet*)primitiveMetas;
- (void)setPrimitiveMetas:(NSMutableSet*)value;

@end
