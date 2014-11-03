#import "_CCLocalEvent.h"

typedef enum : int16_t {
    CCNetworkEventAddressAdded,
    CCNetworkEventListAdded,
    
    CCNetworkEventListRemoved,
    CCNetworkEventAddressRemoved,
    
    CCNetworkEventAddressMovedToList,
    CCNetworkEventAddressMovedFromList,
    
    CCNetworkEventAddressUpdated,
    CCNetworkEventListUpdated,

    CCNetworkEventAddressUserDataUpdated,
} CCNetworkEventEvent;

@interface CCLocalEvent : _CCLocalEvent {}

@end
