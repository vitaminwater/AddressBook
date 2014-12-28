#import "_CCAuthMethod.h"

@interface CCAuthMethod : _CCAuthMethod {}

@property (nonatomic, strong) NSDictionary* infosDict;

- (NSDictionary *)requestDict;

@end
