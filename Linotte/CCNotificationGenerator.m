//
//  CCNotificationGenerator.m
//  Linotte
//
//  Created by stant on 14/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCNotificationGenerator.h"

#import "CCCoreDataStack.h"

#import <SSKeyChain/SSKeychain.h>

#import "NSString+CCLocalizedString.h"

#import <Mixpanel/Mixpanel.h>

#import "CCAddress.h"
#import "CCCategory.h"

@implementation CCNotificationGenerator

#pragma mark - CCGeohashMonitorDelegate method

- (void)didEnterGeohashes:(NSArray *)geohash
{
    // [CCNotificationGenerator scheduleTestLocalNotification:0];
    
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
    
    NSDate *date = [[NSDate date] dateByAddingTimeInterval:-3600 * 8];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"geohash IN %@ && (lastnotif = nil || lastnotif < %@) && notify = %@", geohash, date, @YES];
    [fetchRequest setPredicate:predicate];
    
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    
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

    [[CCCoreDataStack sharedInstance] saveContext];
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    [[Mixpanel sharedInstance] track:@"Local notification sent" properties:localNotification.userInfo];
}

#pragma mark - private methods

- (void)configureLocalNotificationForAddress:(CCAddress *)address localNotification:(UILocalNotification *)localNotification
{
    CCCategory *category = [address.categories.allObjects firstObject];
    NSDictionary *userInfo = @{@"addressNotificationId" : address.notificationId}; // TODO set notification ID on migration
    int notifRand = rand() % 4 + 1;
    
    if (category == nil)
        localNotification.alertBody = [NSString localizedStringByReplacingFromDictionnary:@{@"[PlaceName]" : address.name} localizedKey:[NSString stringWithFormat:@"NOTIFICATION_%d_0", notifRand]];
    else
        localNotification.alertBody = [NSString localizedStringByReplacingFromDictionnary:@{@"[PlaceName]" : address.name, @"[Category]" : category.name} localizedKey:[NSString stringWithFormat:@"NOTIFICATION_%d", notifRand]];
    
    localNotification.userInfo = userInfo;
    
    address.lastnotif = [NSDate date];
}

- (void)configureLocalNotificationForAddresses:(NSArray *)addresses localNotification:(UILocalNotification *)localNotification
{
    NSMutableString *alertBody = [[NSString localizedStringByReplacingFromDictionnary:@{@"[N]" : [@([addresses count]) stringValue]} localizedKey:@"NOTIFICATION_MULTI"] mutableCopy];
    NSDictionary *userInfo = @{@"multiple" : @(YES)};
    
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
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
    
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    
    for (CCAddress *address in results) {
        NSLog(@"%@ %@", address.name, address.lastnotif);
    }
}

+ (void)resetLastNotif
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
    
    NSDate *date = [[NSDate date] dateByAddingTimeInterval:-3600 * 24 * 2];
    
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    
    for (CCAddress *address in results) {
        address.lastnotif = date;
    }
    
    [[CCCoreDataStack sharedInstance] saveContext];
}

#define kCCKeyChainServiceName @"kCCKeyChainServiceNameDebug32"
#define kCCAccessTokenAccountName @"kCCAccessTokenAccountNameDebug"
#define kCCRefreshTokenAccountName @"kCCRefreshTokenAccountNameDebug"
#define kCCExpireTimeStampAccountName @"kCCExpireTimeStampAccountNameDebug"
#define kCCUserIdentifierAccountName @"kCCUserIdentifierAccountNameDebug"

+ (void)scheduleTestLocalNotification:(NSUInteger)delay
{
    NSError *error = NULL;
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
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

#pragma mark - Singleton method

+ (instancetype)sharedInstance
{
    static id instance = nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        instance = [self new];
    });
    
    return instance;
}

@end
