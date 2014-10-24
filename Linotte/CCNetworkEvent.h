#import "_CCNetworkEvent.h"

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

@interface CCNetworkEvent : _CCNetworkEvent {}

@end
