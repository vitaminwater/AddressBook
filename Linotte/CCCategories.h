#import "_CCCategories.h"

@class RKObjectMapping;
@class RKEntityMapping;

@interface CCCategories : _CCCategories {}

+ (RKObjectMapping *)requestObjectMapping;
+ (RKEntityMapping *)responseEntityMapping;

@end
