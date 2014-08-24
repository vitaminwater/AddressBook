#import "_CCAddress.h"


@class RKEntityMapping;
@class RKObjectMapping;

@interface CCAddress : _CCAddress {}

+ (RKObjectMapping *)requestPOSTObjectMapping;
+ (RKEntityMapping *)responsePOSTEntityMapping;

@end
