// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CCList.h instead.

#import <CoreData/CoreData.h>

extern const struct CCListAttributes {
	__unsafe_unretained NSString *avgInactiveDays;
	__unsafe_unretained NSString *icon;
	__unsafe_unretained NSString *identifier;
	__unsafe_unretained NSString *isdefault;
	__unsafe_unretained NSString *lastDateUpdate;
	__unsafe_unretained NSString *lastOpened;
	__unsafe_unretained NSString *lastZoneRefreshLatitude;
	__unsafe_unretained NSString *lastZoneRefreshLongitude;
	__unsafe_unretained NSString *lastZonesRefresh;
	__unsafe_unretained NSString *localIdentifier;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *notify;
	__unsafe_unretained NSString *owned;
	__unsafe_unretained NSString *provider;
	__unsafe_unretained NSString *providerId;
} CCListAttributes;

extern const struct CCListRelationships {
	__unsafe_unretained NSString *addressMetas;
	__unsafe_unretained NSString *addresses;
	__unsafe_unretained NSString *metas;
	__unsafe_unretained NSString *serverEvents;
	__unsafe_unretained NSString *zones;
} CCListRelationships;

@class CCAddressMeta;
@class CCAddress;
@class CCListMeta;
@class CCServerEvent;
@class CCListZone;

@interface CCListID : NSManagedObjectID {}
@end

@interface _CCList : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) CCListID* objectID;

@property (nonatomic, strong) NSNumber* avgInactiveDays;

@property (atomic) double avgInactiveDaysValue;
- (double)avgInactiveDaysValue;
- (void)setAvgInactiveDaysValue:(double)value_;

//- (BOOL)validateAvgInactiveDays:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* icon;

//- (BOOL)validateIcon:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* identifier;

//- (BOOL)validateIdentifier:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isdefault;

@property (atomic) BOOL isdefaultValue;
- (BOOL)isdefaultValue;
- (void)setIsdefaultValue:(BOOL)value_;

//- (BOOL)validateIsdefault:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* lastDateUpdate;

//- (BOOL)validateLastDateUpdate:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* lastOpened;

//- (BOOL)validateLastOpened:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* lastZoneRefreshLatitude;

@property (atomic) double lastZoneRefreshLatitudeValue;
- (double)lastZoneRefreshLatitudeValue;
- (void)setLastZoneRefreshLatitudeValue:(double)value_;

//- (BOOL)validateLastZoneRefreshLatitude:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* lastZoneRefreshLongitude;

@property (atomic) double lastZoneRefreshLongitudeValue;
- (double)lastZoneRefreshLongitudeValue;
- (void)setLastZoneRefreshLongitudeValue:(double)value_;

//- (BOOL)validateLastZoneRefreshLongitude:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* lastZonesRefresh;

//- (BOOL)validateLastZonesRefresh:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* localIdentifier;

//- (BOOL)validateLocalIdentifier:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* notify;

@property (atomic) BOOL notifyValue;
- (BOOL)notifyValue;
- (void)setNotifyValue:(BOOL)value_;

//- (BOOL)validateNotify:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* owned;

@property (atomic) BOOL ownedValue;
- (BOOL)ownedValue;
- (void)setOwnedValue:(BOOL)value_;

//- (BOOL)validateOwned:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* provider;

//- (BOOL)validateProvider:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* providerId;

//- (BOOL)validateProviderId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) CCAddressMeta *addressMetas;

//- (BOOL)validateAddressMetas:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *addresses;

- (NSMutableSet*)addressesSet;

@property (nonatomic, strong) NSSet *metas;

- (NSMutableSet*)metasSet;

@property (nonatomic, strong) NSSet *serverEvents;

- (NSMutableSet*)serverEventsSet;

@property (nonatomic, strong) NSSet *zones;

- (NSMutableSet*)zonesSet;

@end

@interface _CCList (AddressesCoreDataGeneratedAccessors)
- (void)addAddresses:(NSSet*)value_;
- (void)removeAddresses:(NSSet*)value_;
- (void)addAddressesObject:(CCAddress*)value_;
- (void)removeAddressesObject:(CCAddress*)value_;

@end

@interface _CCList (MetasCoreDataGeneratedAccessors)
- (void)addMetas:(NSSet*)value_;
- (void)removeMetas:(NSSet*)value_;
- (void)addMetasObject:(CCListMeta*)value_;
- (void)removeMetasObject:(CCListMeta*)value_;

@end

@interface _CCList (ServerEventsCoreDataGeneratedAccessors)
- (void)addServerEvents:(NSSet*)value_;
- (void)removeServerEvents:(NSSet*)value_;
- (void)addServerEventsObject:(CCServerEvent*)value_;
- (void)removeServerEventsObject:(CCServerEvent*)value_;

@end

@interface _CCList (ZonesCoreDataGeneratedAccessors)
- (void)addZones:(NSSet*)value_;
- (void)removeZones:(NSSet*)value_;
- (void)addZonesObject:(CCListZone*)value_;
- (void)removeZonesObject:(CCListZone*)value_;

@end

@interface _CCList (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveAvgInactiveDays;
- (void)setPrimitiveAvgInactiveDays:(NSNumber*)value;

- (double)primitiveAvgInactiveDaysValue;
- (void)setPrimitiveAvgInactiveDaysValue:(double)value_;

- (NSString*)primitiveIcon;
- (void)setPrimitiveIcon:(NSString*)value;

- (NSString*)primitiveIdentifier;
- (void)setPrimitiveIdentifier:(NSString*)value;

- (NSNumber*)primitiveIsdefault;
- (void)setPrimitiveIsdefault:(NSNumber*)value;

- (BOOL)primitiveIsdefaultValue;
- (void)setPrimitiveIsdefaultValue:(BOOL)value_;

- (NSDate*)primitiveLastDateUpdate;
- (void)setPrimitiveLastDateUpdate:(NSDate*)value;

- (NSDate*)primitiveLastOpened;
- (void)setPrimitiveLastOpened:(NSDate*)value;

- (NSNumber*)primitiveLastZoneRefreshLatitude;
- (void)setPrimitiveLastZoneRefreshLatitude:(NSNumber*)value;

- (double)primitiveLastZoneRefreshLatitudeValue;
- (void)setPrimitiveLastZoneRefreshLatitudeValue:(double)value_;

- (NSNumber*)primitiveLastZoneRefreshLongitude;
- (void)setPrimitiveLastZoneRefreshLongitude:(NSNumber*)value;

- (double)primitiveLastZoneRefreshLongitudeValue;
- (void)setPrimitiveLastZoneRefreshLongitudeValue:(double)value_;

- (NSDate*)primitiveLastZonesRefresh;
- (void)setPrimitiveLastZonesRefresh:(NSDate*)value;

- (NSString*)primitiveLocalIdentifier;
- (void)setPrimitiveLocalIdentifier:(NSString*)value;

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (NSNumber*)primitiveNotify;
- (void)setPrimitiveNotify:(NSNumber*)value;

- (BOOL)primitiveNotifyValue;
- (void)setPrimitiveNotifyValue:(BOOL)value_;

- (NSNumber*)primitiveOwned;
- (void)setPrimitiveOwned:(NSNumber*)value;

- (BOOL)primitiveOwnedValue;
- (void)setPrimitiveOwnedValue:(BOOL)value_;

- (NSString*)primitiveProvider;
- (void)setPrimitiveProvider:(NSString*)value;

- (NSString*)primitiveProviderId;
- (void)setPrimitiveProviderId:(NSString*)value;

- (CCAddressMeta*)primitiveAddressMetas;
- (void)setPrimitiveAddressMetas:(CCAddressMeta*)value;

- (NSMutableSet*)primitiveAddresses;
- (void)setPrimitiveAddresses:(NSMutableSet*)value;

- (NSMutableSet*)primitiveMetas;
- (void)setPrimitiveMetas:(NSMutableSet*)value;

- (NSMutableSet*)primitiveServerEvents;
- (void)setPrimitiveServerEvents:(NSMutableSet*)value;

- (NSMutableSet*)primitiveZones;
- (void)setPrimitiveZones:(NSMutableSet*)value;

@end
