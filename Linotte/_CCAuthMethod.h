// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CCAuthMethod.h instead.

#import <CoreData/CoreData.h>

extern const struct CCAuthMethodAttributes {
	__unsafe_unretained NSString *infos;
	__unsafe_unretained NSString *signup;
	__unsafe_unretained NSString *type;
} CCAuthMethodAttributes;

@interface CCAuthMethodID : NSManagedObjectID {}
@end

@interface _CCAuthMethod : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) CCAuthMethodID* objectID;

@property (nonatomic, strong) NSString* infos;

//- (BOOL)validateInfos:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* signup;

@property (atomic) BOOL signupValue;
- (BOOL)signupValue;
- (void)setSignupValue:(BOOL)value_;

//- (BOOL)validateSignup:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* type;

//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;

@end

@interface _CCAuthMethod (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveInfos;
- (void)setPrimitiveInfos:(NSString*)value;

- (NSNumber*)primitiveSignup;
- (void)setPrimitiveSignup:(NSNumber*)value;

- (BOOL)primitiveSignupValue;
- (void)setPrimitiveSignupValue:(BOOL)value_;

@end
