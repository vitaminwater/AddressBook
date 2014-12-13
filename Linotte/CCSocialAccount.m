#import "CCSocialAccount.h"

#import <SSKeychain/SSKeychain.h>

#define kCCSocialAccountServiceKey @"kCCSocialAccountServiceKey"

@interface CCSocialAccount ()

// Private interface goes here.

@end

@implementation CCSocialAccount

@dynamic authToken;
@dynamic refreshToken;

- (NSString *)authToken
{
    if (self.authTokenKey == nil)
        return nil;
    return [SSKeychain passwordForService:kCCSocialAccountServiceKey account:self.authTokenKey];
}

- (void)setAuthToken:(NSString *)authToken
{
    if (self.authTokenKey == nil)
        self.authTokenKey = [[NSUUID UUID] UUIDString];
    
    NSError *error = nil;
    if ([SSKeychain setPassword:authToken forService:kCCSocialAccountServiceKey account:self.authTokenKey error:&error] == NO)
        CCLog(@"%@", error);
}

- (NSString *)refreshToken
{
    if (self.refreshTokenKey == nil)
        return nil;
    return [SSKeychain passwordForService:kCCSocialAccountServiceKey account:self.refreshTokenKey];
}

- (void)setRefreshToken:(NSString *)refreshToken
{
    if (self.refreshTokenKey == nil)
        self.refreshTokenKey = [[NSUUID UUID] UUIDString];
    NSError *error = nil;
    if ([SSKeychain setPassword:refreshToken forService:kCCSocialAccountServiceKey account:self.refreshTokenKey error:&error] == NO)
        CCLog(@"%@", error);
}

@end
