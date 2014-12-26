#import "CCAuthMethod.h"

@interface CCAuthMethod ()

// Private interface goes here.

@end

@implementation CCAuthMethod

@synthesize infos;

- (NSDictionary *)requestDict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.infos options:0 error:&error];
    NSString *infosString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    if (error != nil) {
        CCLog(@"%@", error);
        return nil;
    }
    
    return @{@"type" : self.type, @"infos" : infosString};
}

@end
