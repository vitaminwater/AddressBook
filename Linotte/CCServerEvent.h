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
    CCServerEventListUserDataUpdated,
    CCServerEventListAdded,
    CCServerEventListRemoved,
} CCServerEventEvent;

@interface CCServerEvent : _CCServerEvent {}

+ (CCServerEvent *)insertInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDict:(NSDictionary *)dict;
+ (NSArray *)eventsWithEventType:(CCServerEventEvent)event list:(CCList *)list;
+ (void)deleteEvents:(NSArray *)events;

@end
