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
	__unsafe_unretained NSString *longitude;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *sent;
} CCAddressAttributes;

extern const struct CCAddressRelationships {
	__unsafe_unretained NSString *categories;
} CCAddressRelationships;

extern const struct CCAddressFetchedProperties {
} CCAddressFetchedProperties;

@class CCCategory;











@interface CCAddressID : NSManagedObjectID {}
@end

@interface _CCAddress : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CCAddressID*)objectID;





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





@property (nonatomic, strong) NSNumber* sent;



@property BOOL sentValue;
- (BOOL)sentValue;
- (void)setSentValue:(BOOL)value_;

//- (BOOL)validateSent:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *categories;

- (NSMutableSet*)categoriesSet;





@end

@interface _CCAddress (CoreDataGeneratedAccessors)

- (void)addCategories:(NSSet*)value_;
- (void)removeCategories:(NSSet*)value_;
- (void)addCategoriesObject:(CCCategory*)value_;
- (void)removeCategoriesObject:(CCCategory*)value_;

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




- (NSNumber*)primitiveLongitude;
- (void)setPrimitiveLongitude:(NSNumber*)value;

- (double)primitiveLongitudeValue;
- (void)setPrimitiveLongitudeValue:(double)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitiveSent;
- (void)setPrimitiveSent:(NSNumber*)value;

- (BOOL)primitiveSentValue;
- (void)setPrimitiveSentValue:(BOOL)value_;





- (NSMutableSet*)primitiveCategories;
- (void)setPrimitiveCategories:(NSMutableSet*)value;


@end
