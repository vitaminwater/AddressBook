#import "_CCNetworkEvent.h"

typedef enum : int16_t {
    CCNetworkEventEventAddressAdded,
    CCNetworkEventEventListAdded,
    
    CCNetworkEventEventListRemoved,
    
    CCNetworkEventEventAddressMovedToList,
    CCNetworkEventEventAddressMovedFromList,
    
    CCNetworkEventEventAddressUpdated,
    CCNetworkEventEventListUpdated,
} CCNetworkEventEvent;

@interface CCNetworkEvent : _CCNetworkEvent {}

@end
