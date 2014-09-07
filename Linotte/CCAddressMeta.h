#import "_CCAddressMeta.h"

@class RKEntityMapping;
@class RKObjectMapping;

@interface CCAddressMeta : _CCAddressMeta {}

+ (RKEntityMapping *)responseGETEntityMapping;
+ (RKObjectMapping *)requestPOSTObjectMapping;
+ (RKEntityMapping *)responsePOSTEntityMapping;

@end
