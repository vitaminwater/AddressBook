//
//  CCNotificationGenerator.m
//  Linotte
//
//  Created by stant on 14/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCNotificationGenerator.h"

#import "CCLinotteCoreDataStack.h"
#import "CCModelChangeMonitor.h"

#import <SSKeyChain/SSKeychain.h>

#import "NSString+CCLocalizedString.h"

#import <Mixpanel/Mixpanel.h>

#import "CCAddress.h"
#import "CCMetaProtocol.h"

@implementation CCNotificationGenerator

#pragma mark - CCGeohashMonitorDelegate method

- (void)didEnterGeohashes:(NSArray *)geohash
{
    // [CCNotificationGenerator scheduleTestLocalNotification:0];
    
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
    
    NSDate *date = [[NSDate date] dateByAddingTimeInterval:-3600 * 8];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(notify = %@ || ANY lists.notify = %@) && geohash IN %@ && (lastnotif = nil || lastnotif < %@)", @YES, @YES, geohash, date];
    [fetchRequest setPredicate:predicate];
    
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        CCLog(@"%@", error);
        return;
    }
    
    if ([results count] == 0) {
        return;
    }
    
    UILocalNotification *localNotification = [UILocalNotification new];
    
    localNotification.alertAction = @"Linotte";
    localNotification.soundName = @"default_notification.caf";
    localNotification.hasAction = YES;
    
    localNotification.applicationIconBadgeNumber = [results count];
    
    if ([results count] == 1)
        [self configureLocalNotificationForAddress:[results firstObject] localNotification:localNotification];
    else
        [self configureLocalNotificationForAddresses:results localNotification:localNotification];

    [[CCLinotteCoreDataStack sharedInstance] saveContext];
    
    [[CCModelChangeMonitor sharedInstance] addressesDidNotify:results];

    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    [[Mixpanel sharedInstance] track:@"Local notification sent" properties:localNotification.userInfo];
}

#pragma mark - private methods

- (void)configureLocalNotificationForAddress:(CCAddress *)address localNotification:(UILocalNotification *)localNotification
{
    id<CCMetaProtocol> notificationMeta = [[address metasForActions:@[@"notification_info"]] firstObject];
    NSDictionary *userInfo = @{@"addressLocalIdentifier" : address.localIdentifier}; // TODO set notification ID on migration
    int notifRand = rand() % 4 + 1;
    
    if (notificationMeta == nil || notificationMeta.content[@"name"] == nil)
        localNotification.alertBody = [NSString localizedStringByReplacingFromDictionnary:@{@"[PlaceName]" : address.name} localizedKey:[NSString stringWithFormat:@"NOTIFICATION_%d_0", notifRand]];
    else
        localNotification.alertBody = [NSString localizedStringByReplacingFromDictionnary:@{@"[PlaceName]" : address.name, @"[Category]" : notificationMeta.content[@"name"]} localizedKey:[NSString stringWithFormat:@"NOTIFICATION_%d", notifRand]];
    
    localNotification.userInfo = userInfo;
    
    address.lastnotif = [NSDate date];
}

- (void)configureLocalNotificationForAddresses:(NSArray *)addresses localNotification:(UILocalNotification *)localNotification
{
    NSMutableString *alertBody = [[NSString localizedStringByReplacingFromDictionnary:@{@"[N]" : [@([addresses count]) stringValue]} localizedKey:@"NOTIFICATION_MULTI"] mutableCopy];
    NSDictionary *userInfo = @{@"multiple" : @YES};
    
    for (CCAddress *address in addresses) {
        NSString *sep = @", ";
        
        if (address == [addresses lastObject])
            sep = [NSString stringWithFormat:@" %@ ", NSLocalizedString(@"NOTIFICATION_AND", @"")];
        else if (address == [addresses firstObject])
            sep = @" ";
        [alertBody appendFormat:@"%@%@", sep, address.name];
        
        address.lastnotif = [NSDate date];
    }
    
    [alertBody appendString:@"."];
    
    localNotification.userInfo = userInfo;
    localNotification.alertBody = alertBody;
}

#pragma mark - testing methods

+ (void)printLastNotif
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
    
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        NSLog(@"%@", error);
        return;
    }
    
    for (CCAddress *address in results) {
        NSLog(@"%@ %@", address.name, address.lastnotif);
    }
}

+ (void)resetLastNotif
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
    
    NSDate *date = [[NSDate date] dateByAddingTimeInterval:-3600 * 24 * 2];
    
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        NSLog(@"%@", error);
        return;
    }
    
    for (CCAddress *address in results) {
        address.lastnotif = date;
    }
    
    [[CCLinotteCoreDataStack sharedInstance] saveContext];
}

#define kCCKeyChainServiceName @"kCCKeyChainServiceNameDebug32"
#define kCCAccessTokenAccountName @"kCCAccessTokenAccountNameDebug"
#define kCCRefreshTokenAccountName @"kCCRefreshTokenAccountNameDebug"
#define kCCExpireTimeStampAccountName @"kCCExpireTimeStampAccountNameDebug"
#define kCCUserIdentifierAccountName @"kCCUserIdentifierAccountNameDebug"

+ (void)scheduleTestLocalNotification:(NSUInteger)delay
{
    NSError *error = NULL;
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
    
    NSUInteger nAddresses = [managedObjectContext countForFetchRequest:fetchRequest error:&error];
    
    NSString *accessToken = [SSKeychain passwordForService:kCCKeyChainServiceName account:kCCAccessTokenAccountName];
    NSString *refreshToken = [SSKeychain passwordForService:kCCKeyChainServiceName account:kCCRefreshTokenAccountName];
    NSString *identifier = [SSKeychain passwordForService:kCCKeyChainServiceName account:kCCUserIdentifierAccountName];
    NSString *expireTimeStamp = [SSKeychain passwordForService:kCCKeyChainServiceName account:kCCExpireTimeStampAccountName];
    
    UILocalNotification *localNotification = [UILocalNotification new];
    
    localNotification.alertAction = @"Linotte";
    localNotification.soundName = @"default_notification.caf";
    localNotification.alertBody = [NSString stringWithFormat:@"Nb of addresses: %lu, %lu, %lu, %lu, %lu", (unsigned long)nAddresses, (unsigned long)[accessToken length], (unsigned long)[refreshToken length], (unsigned long)[identifier length], (unsigned long)[expireTimeStamp length]];
    localNotification.hasAction = YES;
    
    localNotification.applicationIconBadgeNumber = 1;
    
    if (delay) {
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:delay];
        
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    } else {
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
}

@end
