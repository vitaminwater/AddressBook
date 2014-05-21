// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CCCategories.h instead.

#import <CoreData/CoreData.h>


extern const struct CCCategoriesAttributes {
	__unsafe_unretained NSString *identifier;
	__unsafe_unretained NSString *name;
} CCCategoriesAttributes;

extern const struct CCCategoriesRelationships {
	__unsafe_unretained NSString *address;
} CCCategoriesRelationships;

extern const struct CCCategoriesFetchedProperties {
} CCCategoriesFetchedProperties;

@class CCAddress;




@interface CCCategoriesID : NSManagedObjectID {}
@end

@interface _CCCategories : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CCCategoriesID*)objectID;





@property (nonatomic, strong) NSString* identifier;



//- (BOOL)validateIdentifier:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) CCAddress *address;

//- (BOOL)validateAddress:(id*)value_ error:(NSError**)error_;





@end

@interface _CCCategories (CoreDataGeneratedAccessors)

@end

@interface _CCCategories (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveIdentifier;
- (void)setPrimitiveIdentifier:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (CCAddress*)primitiveAddress;
- (void)setPrimitiveAddress:(CCAddress*)value;


@end
