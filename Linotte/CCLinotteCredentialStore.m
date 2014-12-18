//
//  CCLinotteCredentialStore.m
//  Linotte
//
//  Created by stant on 17/12/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCLinotteCredentialStore.h"

#import <SSKeychain/SSKeychain.h>

#import "CCLinotteAPI.h"
#import "CCLinotteCoreDataStack.h"

#import "CCSocialAccount.h"

// SSKeychain accounts
#if defined(DEBUG)
#define kCCKeyChainServiceName @"kCCKeyChainServiceNameDebug56"

#define kCCAccessTokenAccountName @"kCCAccessTokenAccountNameDebug"
#define kCCRefreshTokenAccountName @"kCCRefreshTokenAccountNameDebug"
#define kCCExpirationDateAccountName @"kCCExpirationDateAccountName"

#define kCCDeviceIdentifierAccountName @"kCCDeviceIdentifierAccountNameDebug"

#define kCCUserIdentifierAccountName @"kCCUserIdentifierAccountNameDebug"
#define kCCUserEmailAccountName @"kCCUserEmailAccountNameDebug"
#define kCCUserPasswordAccountName @"kCCUserPasswordAccountNameDebug"

#else
// #define kCCKeyChainServiceName @"kCCKeyChainServiceName6" // test
#define kCCKeyChainServiceName @"kCCKeyChainServiceName1000" // Apstore

#define kCCAccessTokenAccountName @"kCCAccessTokenAccountName"
#define kCCRefreshTokenAccountName @"kCCRefreshTokenAccountName"
#define kCCExpirationDateAccountName @"kCCExpirationDateAccountName"

#define kCCDeviceIdentifierAccountName @"kCCDeviceIdentifierAccountName"

#define kCCUserIdentifierAccountName @"kCCUserIdentifierAccountName"
#define kCCUserEmailAccountName @"kCCUserEmailAccountName"
#define kCCUserPasswordAccountName @"kCCUserPasswordAccountName"

#endif

@implementation CCLinotteCredentialStore
{
    CCLinotteAPI *_linotteAPI;
}

@dynamic accessToken, refreshToken, expirationDate;
@dynamic deviceId;
@dynamic email, password;
@dynamic storeState;

- (id)initWithLinotteAPI:(CCLinotteAPI *)linotteAPI
{
    self = [super init];
    if (self) {
        _linotteAPI = linotteAPI;
        
        [SSKeychain setAccessibilityType:kSecAttrAccessibleAlways];
    }
    return self;
}

- (void)addFacebookAccount:(id<FBGraphUser>)user
{
    FBAccessTokenData *accessTokenData = [FBSession activeSession].accessTokenData;

    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    CCSocialAccount *socialAccount = [CCSocialAccount insertInManagedObjectContext:managedObjectContext];
    socialAccount.socialIdentifier = user.objectID;
    socialAccount.mediaIdentifier = @"facebook";
    socialAccount.authToken = accessTokenData.accessToken;
    socialAccount.expirationDate = accessTokenData.expirationDate;
    [[CCLinotteCoreDataStack sharedInstance] saveContext];
}

- (BOOL)hasSocialAccountToSend
{
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCSocialAccount entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sent = %@", @NO];
    
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    
    NSUInteger count = [managedObjectContext countForFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        CCLog(@"%@", error);
        return NO;
    }
    
    return count != 0;
}

- (CCSocialAccount *)nextSocialAccountToSend
{
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCSocialAccount entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sent = %@", @NO];
    
    [fetchRequest setPredicate:predicate];
    fetchRequest.fetchLimit = 1;
    
    NSError *error;
    NSArray *socialAccount = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        CCLog(@"%@", error);
        return nil;
    }
    
    if ([socialAccount count] == 0)
        return nil;
    
    return [socialAccount firstObject];
}

- (void)logout
{
    self.accessToken = nil;
    self.refreshToken = nil;
    self.expirationDate = nil;
    self.deviceId = nil;
    self.identifer = nil;
    self.email = nil;
    self.password = nil;
    
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCSocialAccount entityName]];
    
    NSError *error;
    NSArray *socialAccounts = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        CCLog(@"%@", error);
        return;
    }
    
    for (CCSocialAccount *socialAccount in socialAccounts) {
        [managedObjectContext deleteObject:socialAccount];
    }
    [[CCLinotteCoreDataStack sharedInstance] saveContext];
}

#pragma mark - helper methods

- (void)setValueInKeychain:(NSString *)value key:(NSString *)key
{
    NSError *error;
    
    if (value == nil) {
        if ([SSKeychain deletePasswordForService:kCCKeyChainServiceName account:key] == NO) {
            CCLog(@"%@", error);
        }
        return;
    }
    
    if ([SSKeychain setPassword:value forService:kCCKeyChainServiceName account:key error:&error] == NO) {
        CCLog(@"%@", error);
    }
}

- (NSString *)getValueInKeychain:(NSString *)key
{
    return [SSKeychain passwordForService:kCCKeyChainServiceName account:kCCDeviceIdentifierAccountName];
}

#pragma mark - setter methods

- (void)setAccessToken:(NSString *)accessToken
{
    [self setValueInKeychain:accessToken key:kCCAccessTokenAccountName];
}

- (void)setRefreshToken:(NSString *)refreshToken
{
    [self setValueInKeychain:refreshToken key:kCCRefreshTokenAccountName];
}

- (void)setExpirationDate:(NSDate *)expirationDate
{
    NSString *expirationDateString = [_linotteAPI stringFromDate:expirationDate];
    [self setValueInKeychain:expirationDateString key:kCCExpirationDateAccountName];
}

- (void)setDeviceId:(NSString *)deviceId
{
    [self setValueInKeychain:deviceId key:kCCDeviceIdentifierAccountName];
}

- (void)setIdentifier:(NSString *)identifier
{
    [self setValueInKeychain:identifier key:kCCUserIdentifierAccountName];
}

- (void)setEmail:(NSString *)email
{
    [self setValueInKeychain:email key:kCCUserEmailAccountName];
}

- (void)setPassword:(NSString *)password
{
    [self setValueInKeychain:password key:kCCUserPasswordAccountName];
}

#pragma mark - setter methods

- (CCCredentialStoreState)storeState
{
    if ([[SSKeychain accountsForService:kCCKeyChainServiceName] count] == 0)
        return kCCFirstStart;
    else if (self.email != nil && self.identifer == nil)
        return kCCCreateAccount;
    else if (self.email != nil && self.identifer != nil && self.accessToken == nil)
        return kCCAuthenticate;
    else if ([[[NSDate date] dateByAddingTimeInterval: - 60 * 60 * 24 * 30] compare:self.expirationDate] == NSOrderedDescending)
        return kCCRequestRefreshToken;
    else if (self.deviceId == nil)
        return kCCCreateDeviceId;
    else if ([self hasSocialAccountToSend])
        return kCCAssociateSocialAccount;
    else
        return kCCLoggedIn;
}

- (NSString *)accessToken
{
    return [self getValueInKeychain:kCCAccessTokenAccountName];
}

- (NSString *)refreshToken
{
    return [self getValueInKeychain:kCCRefreshTokenAccountName];
}

- (NSDate *)expirationDate
{
    NSString *expirationDateString = [self getValueInKeychain:kCCExpirationDateAccountName];

    return [_linotteAPI dateFromString:expirationDateString];
}

- (NSString *)deviceId
{
    return [self getValueInKeychain:kCCDeviceIdentifierAccountName];
}

- (NSString *)identifer
{
    return [self getValueInKeychain:kCCUserIdentifierAccountName];
}

- (NSString *)email
{
    return [self getValueInKeychain:kCCUserEmailAccountName];
}

- (NSString *)password
{
    return [self getValueInKeychain:kCCUserPasswordAccountName];
}

@end
