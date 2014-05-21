#import "_CCCategory.h"

@class RKObjectMapping;
@class RKEntityMapping;

@interface CCCategory : _CCCategory {}

+ (RKObjectMapping *)requestObjectMapping;
+ (RKEntityMapping *)responseEntityMapping;

@end
