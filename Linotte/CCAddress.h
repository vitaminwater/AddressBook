#import "_CCAddress.h"


@class RKEntityMapping;
@class RKObjectMapping;

@interface CCAddress : _CCAddress {}

+ (RKObjectMapping *)requestObjectMapping;
+ (RKEntityMapping *)responseEntityMapping;

@end
