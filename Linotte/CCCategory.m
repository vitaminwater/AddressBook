#import "CCCategory.h"

#import <RestKit/RestKit.h>


@interface CCCategory ()

// Private interface goes here.

@end


@implementation CCCategory

+ (RKObjectMapping *)requestObjectMapping
{
    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    
    [objectMapping addAttributeMappingsFromArray:@[CCCategoryAttributes.identifier, CCCategoryAttributes.name]];
    
    return objectMapping;
}

+ (RKEntityMapping *)responseEntityMapping
{
    return nil;
}

@end
