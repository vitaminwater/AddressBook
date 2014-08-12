//
//  CCNotificationGenerator.m
//  Linotte
//
//  Created by stant on 14/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCNotificationGenerator.h"

#import "NSString+CCLocalizedString.h"

#import <RestKit/RestKit.h>

#import "CCAddress.h"
#import "CCCategory.h"

@implementation CCNotificationGenerator

- (void)didEnterGeohash:(NSArray *)geohash
{
    NSManagedObjectContext *managedObjectContext = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
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
    
    localNotification.applicationIconBadgeNumber = [results count];
    
    if ([results count] == 1)
        [self configureLocalNotificationForAddress:[results firstObject] localNotification:localNotification];
    else
        [self configureLocalNotificationForAddresses:results localNotification:localNotification];

    [managedObjectContext saveToPersistentStore:NULL];
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
}

- (void)configureLocalNotificationForAddress:(CCAddress *)address localNotification:(UILocalNotification *)localNotification
{
    CCCategory *category = [address.categories.allObjects firstObject];
    NSDictionary *userInfo = @{@"addressId" : address.identifier};
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
    NSManagedObjectContext *managedObjectContext = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
    
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    
    for (CCAddress *address in results) {
        NSLog(@"%@ %@", address.name, address.lastnotif);
    }
}

+ (void)resetLastNotif
{
    NSManagedObjectContext *managedObjectContext = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
    
    NSDate *date = [[NSDate date] dateByAddingTimeInterval:-3600 * 24 * 2];
    
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    
    for (CCAddress *address in results) {
        address.lastnotif = date;
    }
    
    [managedObjectContext saveToPersistentStore:NULL];
}

#pragma mark - singelton method

+ (instancetype)sharedInstance
{
    static id instance = nil;
    
    if (instance == nil)
        instance = [self new];
    
    return instance;
}

@end
