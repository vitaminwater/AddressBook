#import "_CCAddress.h"


@class RKEntityMapping;
@class RKObjectMapping;

@interface CCAddress : _CCAddress {}

+ (RKObjectMapping *)requestPOSTObjectSlugMapping;
+ (RKEntityMapping *)responseGETEntityMapping;
+ (RKObjectMapping *)requestPOSTObjectMapping;
+ (RKEntityMapping *)responsePOSTEntityMapping;

@end
