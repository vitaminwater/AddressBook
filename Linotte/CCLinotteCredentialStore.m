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

#import "CCAuthMethod.h"

#if defined(DEBUG)

#define kCCKeyChainServiceName @"kCCKeyChainServiceNameDebug79"

#define kCCAccessTokenAccountName @"kCCAccessTokenAccountNameDebug"
#define kCCExpirationDateAccountName @"kCCExpirationDateAccountNameDebug"
#define kCCDeviceIdentifierAccountName @"kCCDeviceIdentifierAccountNameDebug"
#define kCCUserIdentifierAccountName @"kCCUserIdentifierAccountNameDebug"

#else

#define kCCKeyChainServiceName @"kCCKeyChainServiceName1000" // Apstore

#define kCCAccessTokenAccountName @"kCCAccessTokenAccountName"
#define kCCExpirationDateAccountName @"kCCExpirationDateAccountName"
#define kCCDeviceIdentifierAccountName @"kCCDeviceIdentifierAccountName"
#define kCCUserIdentifierAccountName @"kCCUserIdentifierAccountName"

#endif

@implementation CCLinotteCredentialStore
{
    CCLinotteAPI *_linotteAPI;
}

@dynamic accessToken;
@dynamic identifier, deviceId;
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

- (void)addAuthMethodWithEmail:(NSString *)email password:(NSString *)password
{
    NSDictionary *infos = @{@"email" : email, @"password" : password};
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    
    CCAuthMethod *authMethod = nil;
    
    // check if already has an email type auth method
    {
        NSError *error;
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAuthMethod entityName]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type = %@", @"email"];
        [fetchRequest setPredicate:predicate];
        
        NSArray *authMethods = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if (error != nil) {
            CCLog(@"%@", error);
            return;
        }
        
        if ([authMethods count] != 0) {
            authMethod = [authMethods firstObject];
        }
    }
    
    if (authMethod == nil)
        authMethod = [CCAuthMethod insertInManagedObjectContext:managedObjectContext];
    
    authMethod.type = @"email";
    authMethod.infos = infos;
    [[CCLinotteCoreDataStack sharedInstance] saveContext];
}

- (void)addAuthMethodWithFacebookAccount:(id<FBGraphUser>)user
{
    FBAccessTokenData *accessTokenData = [FBSession activeSession].accessTokenData;

    NSString *expirationDateString = [_linotteAPI stringFromDate:accessTokenData.expirationDate];
    NSDictionary *infos = @{@"access_token" : accessTokenData.accessToken, @"identifier" : user.objectID, @"expiration_date" : expirationDateString};
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    CCAuthMethod *unsentAuthMethod = [CCAuthMethod insertInManagedObjectContext:managedObjectContext];
    unsentAuthMethod.type = @"facebook";
    unsentAuthMethod.infos = infos;
    [[CCLinotteCoreDataStack sharedInstance] saveContext];
}

- (BOOL)hasAuthMethodToSend
{
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAuthMethod entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sent = %@", @(NO)];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSUInteger count = [managedObjectContext countForFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        CCLog(@"%@", error);
        return NO;
    }
    
    return count != 0;
}

- (CCAuthMethod *)nextUnsentAuthMethod
{
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAuthMethod entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sent = %@", @(NO)];
    [fetchRequest setPredicate:predicate];
    fetchRequest.fetchLimit = 1;
    
    NSError *error;
    NSArray *authMethods = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        CCLog(@"%@", error);
        return nil;
    }
    
    if ([authMethods count] == 0)
        return nil;
    
    return [authMethods firstObject];
}

- (CCAuthMethod *)firstAuthMethod
{
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAuthMethod entityName]];
    fetchRequest.fetchLimit = 1;
    
    NSError *error;
    NSArray *authMethod = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        CCLog(@"%@", error);
        return nil;
    }
    
    if ([authMethod count] == 0)
        return nil;
    
    return [authMethod firstObject];
}

- (void)logout
{
    self.accessToken = nil;
    self.deviceId = nil;
    self.identifier = nil;
    
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAuthMethod entityName]];
    
    NSError *error;
    NSArray *unsentAuthMethods = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        CCLog(@"%@", error);
        return;
    }
    
    for (CCAuthMethod *unsentAuthMethod in unsentAuthMethods) {
        [managedObjectContext deleteObject:unsentAuthMethod];
    }
    [[CCLinotteCoreDataStack sharedInstance] saveContext];
}

#pragma mark - helper methods

- (void)setValueInKeychain:(NSString *)value key:(NSString *)key
{
    NSError *error;
    
    if (value == nil) {
        [SSKeychain deletePasswordForService:kCCKeyChainServiceName account:key];
        return;
    }
    
    if ([SSKeychain setPassword:value forService:kCCKeyChainServiceName account:key error:&error] == NO) {
        CCLog(@"%@", error);
    }
}

- (NSString *)getValueInKeychain:(NSString *)key
{
    return [SSKeychain passwordForService:kCCKeyChainServiceName account:key];
}

#pragma mark - setter methods

- (void)setAccessToken:(NSString *)accessToken
{
    [self setValueInKeychain:accessToken key:kCCAccessTokenAccountName];
    [_linotteAPI setAuthHTTPHeader:accessToken];
}

- (void)setDeviceId:(NSString *)deviceId
{
    [self setValueInKeychain:deviceId key:kCCDeviceIdentifierAccountName];
    [_linotteAPI setDeviceHTTPHeader:deviceId];
}

- (void)setIdentifier:(NSString *)identifier
{
    [self setValueInKeychain:identifier key:kCCUserIdentifierAccountName];
}

#pragma mark - setter methods

- (CCCredentialStoreState)storeState
{
    if ([[SSKeychain accountsForService:kCCKeyChainServiceName] count] == 0)
        return kCCFirstStart;
    else if (self.deviceId == nil)
        return kCCCreateDeviceId;
    else if ([self hasAuthMethodToSend])
        return kCCSendAuthMethod;
    else
        return kCCLoggedIn;
}

- (NSString *)accessToken
{
    return [self getValueInKeychain:kCCAccessTokenAccountName];
}

- (NSString *)deviceId
{
    return [self getValueInKeychain:kCCDeviceIdentifierAccountName];
}

- (NSString *)identifer
{
    return [self getValueInKeychain:kCCUserIdentifierAccountName];
}

@end
