#import "_CCCategory.h"

@class RKObjectMapping;
@class RKEntityMapping;

@interface CCCategory : _CCCategory {}

+ (RKEntityMapping *)responseGETEntityMapping;
+ (RKObjectMapping *)requestPOSTObjectMapping;
+ (RKEntityMapping *)responsePOSTEntityMapping;

@end
