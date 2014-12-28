// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CCAuthMethod.h instead.

#import <CoreData/CoreData.h>

extern const struct CCAuthMethodAttributes {
	__unsafe_unretained NSString *identifier;
	__unsafe_unretained NSString *infos;
	__unsafe_unretained NSString *sent;
	__unsafe_unretained NSString *type;
} CCAuthMethodAttributes;

@interface CCAuthMethodID : NSManagedObjectID {}
@end

@interface _CCAuthMethod : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) CCAuthMethodID* objectID;

@property (nonatomic, strong) NSString* identifier;

//- (BOOL)validateIdentifier:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* infos;

//- (BOOL)validateInfos:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* sent;

@property (atomic) BOOL sentValue;
- (BOOL)sentValue;
- (void)setSentValue:(BOOL)value_;

//- (BOOL)validateSent:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* type;

//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;

@end

@interface _CCAuthMethod (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveIdentifier;
- (void)setPrimitiveIdentifier:(NSString*)value;

- (NSString*)primitiveInfos;
- (void)setPrimitiveInfos:(NSString*)value;

- (NSNumber*)primitiveSent;
- (void)setPrimitiveSent:(NSNumber*)value;

- (BOOL)primitiveSentValue;
- (void)setPrimitiveSentValue:(BOOL)value_;

@end
