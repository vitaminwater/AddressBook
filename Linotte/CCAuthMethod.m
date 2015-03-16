#import "CCAuthMethod.h"

#import <SSKeychain/SSKeychain.h>

#define kCCAccountName @"kCCLinotteAuthMethodAccountName"

@interface CCAuthMethod ()

// Private interface goes here.

@end

@implementation CCAuthMethod

@dynamic infosDict;

- (void)setInfosDict:(NSDictionary *)infos
{
    NSString *infosUUID = self.infos;
    
    if (infosUUID == nil) {
        infosUUID = [[NSUUID UUID] UUIDString];
        self.infos = infosUUID;
    }
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infos options:0 error:&error];
    NSString *infosJSON = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if (error != nil) {
        CCLog(@"%@", error);
        return;
    }
    
    error = nil;
    [SSKeychain setPassword:infosJSON forService:infosUUID account:kCCAccountName error:&error];
    if (error != nil) {
        CCLog(@"%@", error);
        return;
    }
}

- (NSDictionary *)infosDict
{
    NSString *infosUUID = self.infos;
    
    if (infosUUID == nil)
        return nil;
    
    NSString *infosJSON = [SSKeychain passwordForService:infosUUID account:kCCAccountName];
    
    NSError *error = nil;
    NSDictionary *infos = [NSJSONSerialization JSONObjectWithData:[infosJSON dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    if (error != nil) {
        CCLog(@"", error);
        return nil;
    }
    return infos;
}

- (NSDictionary *)requestDict
{
    NSString *infosUUID = self.infos;
    
    if (infosUUID == nil)
        return nil;
    
    NSString *infosJSON = [SSKeychain passwordForService:infosUUID account:kCCAccountName];
    
    return @{@"type" : self.type, @"infos" : infosJSON};
}

@end
