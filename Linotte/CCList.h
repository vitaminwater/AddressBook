#import "_CCList.h"

@class RKEntityMapping;
@class RKObjectMapping;

@interface CCList : _CCList {}

+ (RKEntityMapping *)responseGETEntityMapping;
+ (RKObjectMapping *)requestPOSTObjectMapping;
+ (RKEntityMapping *)responsePOSTEntityMapping;

@end
