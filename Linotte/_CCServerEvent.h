// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CCServerEvent.h instead.

#import <CoreData/CoreData.h>

extern const struct CCServerEventAttributes {
	__unsafe_unretained NSString *event;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *objectIdentifier;
} CCServerEventAttributes;

extern const struct CCServerEventRelationships {
	__unsafe_unretained NSString *list;
} CCServerEventRelationships;

@class CCList;

@interface CCServerEventID : NSManagedObjectID {}
@end

@interface _CCServerEvent : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) CCServerEventID* objectID;

@property (nonatomic, strong) NSNumber* event;

@property (atomic) int16_t eventValue;
- (int16_t)eventValue;
- (void)setEventValue:(int16_t)value_;

//- (BOOL)validateEvent:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* id;

@property (atomic) int64_t idValue;
- (int64_t)idValue;
- (void)setIdValue:(int64_t)value_;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* objectIdentifier;

//- (BOOL)validateObjectIdentifier:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) CCList *list;

//- (BOOL)validateList:(id*)value_ error:(NSError**)error_;

@end

@interface _CCServerEvent (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveEvent;
- (void)setPrimitiveEvent:(NSNumber*)value;

- (int16_t)primitiveEventValue;
- (void)setPrimitiveEventValue:(int16_t)value_;

- (NSNumber*)primitiveId;
- (void)setPrimitiveId:(NSNumber*)value;

- (int64_t)primitiveIdValue;
- (void)setPrimitiveIdValue:(int64_t)value_;

- (NSString*)primitiveObjectIdentifier;
- (void)setPrimitiveObjectIdentifier:(NSString*)value;

- (CCList*)primitiveList;
- (void)setPrimitiveList:(CCList*)value;

@end
