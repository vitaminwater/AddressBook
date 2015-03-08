// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CCListZone.h instead.

#import <CoreData/CoreData.h>

extern const struct CCListZoneAttributes {
	__unsafe_unretained NSString *firstFetch;
	__unsafe_unretained NSString *geohash;
	__unsafe_unretained NSString *lastAddressFirstFetchDate;
	__unsafe_unretained NSString *lastEventDate;
	__unsafe_unretained NSString *lastUpdate;
	__unsafe_unretained NSString *latitude;
	__unsafe_unretained NSString *longNextRefreshDate;
	__unsafe_unretained NSString *longitude;
	__unsafe_unretained NSString *nAddresses;
	__unsafe_unretained NSString *needsMerge;
	__unsafe_unretained NSString *readyToMerge;
	__unsafe_unretained NSString *shortNextRefreshDate;
	__unsafe_unretained NSString *waitingTime;
} CCListZoneAttributes;

extern const struct CCListZoneRelationships {
	__unsafe_unretained NSString *list;
} CCListZoneRelationships;

@class CCList;

@interface CCListZoneID : NSManagedObjectID {}
@end

@interface _CCListZone : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) CCListZoneID* objectID;

@property (nonatomic, strong) NSNumber* firstFetch;

@property (atomic) BOOL firstFetchValue;
- (BOOL)firstFetchValue;
- (void)setFirstFetchValue:(BOOL)value_;

//- (BOOL)validateFirstFetch:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* geohash;

//- (BOOL)validateGeohash:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* lastAddressFirstFetchDate;

//- (BOOL)validateLastAddressFirstFetchDate:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* lastEventDate;

//- (BOOL)validateLastEventDate:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* lastUpdate;

//- (BOOL)validateLastUpdate:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* latitude;

@property (atomic) double latitudeValue;
- (double)latitudeValue;
- (void)setLatitudeValue:(double)value_;

//- (BOOL)validateLatitude:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* longNextRefreshDate;

//- (BOOL)validateLongNextRefreshDate:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* longitude;

@property (atomic) double longitudeValue;
- (double)longitudeValue;
- (void)setLongitudeValue:(double)value_;

//- (BOOL)validateLongitude:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* nAddresses;

@property (atomic) int16_t nAddressesValue;
- (int16_t)nAddressesValue;
- (void)setNAddressesValue:(int16_t)value_;

//- (BOOL)validateNAddresses:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* needsMerge;

//- (BOOL)validateNeedsMerge:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* readyToMerge;

@property (atomic) BOOL readyToMergeValue;
- (BOOL)readyToMergeValue;
- (void)setReadyToMergeValue:(BOOL)value_;

//- (BOOL)validateReadyToMerge:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* shortNextRefreshDate;

//- (BOOL)validateShortNextRefreshDate:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* waitingTime;

@property (atomic) int32_t waitingTimeValue;
- (int32_t)waitingTimeValue;
- (void)setWaitingTimeValue:(int32_t)value_;

//- (BOOL)validateWaitingTime:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) CCList *list;

//- (BOOL)validateList:(id*)value_ error:(NSError**)error_;

@end

@interface _CCListZone (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveFirstFetch;
- (void)setPrimitiveFirstFetch:(NSNumber*)value;

- (BOOL)primitiveFirstFetchValue;
- (void)setPrimitiveFirstFetchValue:(BOOL)value_;

- (NSString*)primitiveGeohash;
- (void)setPrimitiveGeohash:(NSString*)value;

- (NSDate*)primitiveLastAddressFirstFetchDate;
- (void)setPrimitiveLastAddressFirstFetchDate:(NSDate*)value;

- (NSDate*)primitiveLastEventDate;
- (void)setPrimitiveLastEventDate:(NSDate*)value;

- (NSDate*)primitiveLastUpdate;
- (void)setPrimitiveLastUpdate:(NSDate*)value;

- (NSNumber*)primitiveLatitude;
- (void)setPrimitiveLatitude:(NSNumber*)value;

- (double)primitiveLatitudeValue;
- (void)setPrimitiveLatitudeValue:(double)value_;

- (NSDate*)primitiveLongNextRefreshDate;
- (void)setPrimitiveLongNextRefreshDate:(NSDate*)value;

- (NSNumber*)primitiveLongitude;
- (void)setPrimitiveLongitude:(NSNumber*)value;

- (double)primitiveLongitudeValue;
- (void)setPrimitiveLongitudeValue:(double)value_;

- (NSNumber*)primitiveNAddresses;
- (void)setPrimitiveNAddresses:(NSNumber*)value;

- (int16_t)primitiveNAddressesValue;
- (void)setPrimitiveNAddressesValue:(int16_t)value_;

- (NSString*)primitiveNeedsMerge;
- (void)setPrimitiveNeedsMerge:(NSString*)value;

- (NSNumber*)primitiveReadyToMerge;
- (void)setPrimitiveReadyToMerge:(NSNumber*)value;

- (BOOL)primitiveReadyToMergeValue;
- (void)setPrimitiveReadyToMergeValue:(BOOL)value_;

- (NSDate*)primitiveShortNextRefreshDate;
- (void)setPrimitiveShortNextRefreshDate:(NSDate*)value;

- (NSNumber*)primitiveWaitingTime;
- (void)setPrimitiveWaitingTime:(NSNumber*)value;

- (int32_t)primitiveWaitingTimeValue;
- (void)setPrimitiveWaitingTimeValue:(int32_t)value_;

- (CCList*)primitiveList;
- (void)setPrimitiveList:(CCList*)value;

@end
