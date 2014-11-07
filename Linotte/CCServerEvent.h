#import "_CCServerEvent.h"

typedef enum : int16_t {
    CCServerEventListUpdated = 1,
    CCServerEventListMetaAdded,
    CCServerEventListMetaUpdated,
    CCServerEventListMetaDeleted,
    CCServerEventAddressAddedToList,
    CCServerEventAddressMovedFromList,
    CCServerEventAddressUpdated,
    CCServerEventAddressUserDataUpdated,
    CCServerEventAddressMetaAdded,
    CCServerEventAddressMetaUpdated,
    CCServerEventAddressMetaDeleted,
} CCServerEventEvent;

@interface CCServerEvent : _CCServerEvent {}

+ (CCServerEvent *)insertInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDict:(NSDictionary *)dict;

@end
