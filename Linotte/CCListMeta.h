#import "_CCListMeta.h"

@class RKEntityMapping;
@class RKObjectMapping;

@interface CCListMeta : _CCListMeta {}

+ (RKEntityMapping *)responseGETEntityMapping;
+ (RKObjectMapping *)requestPOSTObjectMapping;
+ (RKEntityMapping *)responsePOSTEntityMapping;

@end
