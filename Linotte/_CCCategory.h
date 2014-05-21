// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CCCategory.h instead.

#import <CoreData/CoreData.h>


extern const struct CCCategoryAttributes {
	__unsafe_unretained NSString *identifier;
	__unsafe_unretained NSString *name;
} CCCategoryAttributes;

extern const struct CCCategoryRelationships {
	__unsafe_unretained NSString *address;
} CCCategoryRelationships;

extern const struct CCCategoryFetchedProperties {
} CCCategoryFetchedProperties;

@class CCAddress;




@interface CCCategoryID : NSManagedObjectID {}
@end

@interface _CCCategory : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CCCategoryID*)objectID;





@property (nonatomic, strong) NSString* identifier;



//- (BOOL)validateIdentifier:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) CCAddress *address;

//- (BOOL)validateAddress:(id*)value_ error:(NSError**)error_;





@end

@interface _CCCategory (CoreDataGeneratedAccessors)

@end

@interface _CCCategory (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveIdentifier;
- (void)setPrimitiveIdentifier:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (CCAddress*)primitiveAddress;
- (void)setPrimitiveAddress:(CCAddress*)value;


@end
