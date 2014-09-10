// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CCList.h instead.

#import <CoreData/CoreData.h>


extern const struct CCListAttributes {
	__unsafe_unretained NSString *expanded;
	__unsafe_unretained NSString *icon;
	__unsafe_unretained NSString *identifier;
	__unsafe_unretained NSString *latitude;
	__unsafe_unretained NSString *longitude;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *provider;
	__unsafe_unretained NSString *providerId;
	__unsafe_unretained NSString *sent;
} CCListAttributes;

extern const struct CCListRelationships {
	__unsafe_unretained NSString *addresses;
	__unsafe_unretained NSString *metas;
} CCListRelationships;

extern const struct CCListFetchedProperties {
} CCListFetchedProperties;

@class CCAddress;
@class CCListMeta;











@interface CCListID : NSManagedObjectID {}
@end

@interface _CCList : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CCListID*)objectID;





@property (nonatomic, strong) NSNumber* expanded;



@property BOOL expandedValue;
- (BOOL)expandedValue;
- (void)setExpandedValue:(BOOL)value_;

//- (BOOL)validateExpanded:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* icon;



//- (BOOL)validateIcon:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* identifier;



//- (BOOL)validateIdentifier:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* latitude;



@property double latitudeValue;
- (double)latitudeValue;
- (void)setLatitudeValue:(double)value_;

//- (BOOL)validateLatitude:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* longitude;



@property double longitudeValue;
- (double)longitudeValue;
- (void)setLongitudeValue:(double)value_;

//- (BOOL)validateLongitude:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* provider;



//- (BOOL)validateProvider:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* providerId;



//- (BOOL)validateProviderId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* sent;



@property BOOL sentValue;
- (BOOL)sentValue;
- (void)setSentValue:(BOOL)value_;

//- (BOOL)validateSent:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *addresses;

- (NSMutableSet*)addressesSet;




@property (nonatomic, strong) NSSet *metas;

- (NSMutableSet*)metasSet;





@end

@interface _CCList (CoreDataGeneratedAccessors)

- (void)addAddresses:(NSSet*)value_;
- (void)removeAddresses:(NSSet*)value_;
- (void)addAddressesObject:(CCAddress*)value_;
- (void)removeAddressesObject:(CCAddress*)value_;

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




- (NSNumber*)primitiveLatitude;
- (void)setPrimitiveLatitude:(NSNumber*)value;

- (double)primitiveLatitudeValue;
- (void)setPrimitiveLatitudeValue:(double)value_;




- (NSNumber*)primitiveLongitude;
- (void)setPrimitiveLongitude:(NSNumber*)value;

- (double)primitiveLongitudeValue;
- (void)setPrimitiveLongitudeValue:(double)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitiveProvider;
- (void)setPrimitiveProvider:(NSString*)value;




- (NSString*)primitiveProviderId;
- (void)setPrimitiveProviderId:(NSString*)value;




- (NSNumber*)primitiveSent;
- (void)setPrimitiveSent:(NSNumber*)value;

- (BOOL)primitiveSentValue;
- (void)setPrimitiveSentValue:(BOOL)value_;





- (NSMutableSet*)primitiveAddresses;
- (void)setPrimitiveAddresses:(NSMutableSet*)value;



- (NSMutableSet*)primitiveMetas;
- (void)setPrimitiveMetas:(NSMutableSet*)value;


@end
