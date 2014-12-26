#import "_CCAuthMethod.h"

@interface CCAuthMethod : _CCAuthMethod {}

@property (nonatomic, strong) NSDictionary* infos;

- (NSDictionary *)requestDict;

@end
