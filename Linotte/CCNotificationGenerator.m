//
//  CCNotificationGenerator.m
//  Linotte
//
//  Created by stant on 14/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCNotificationGenerator.h"

#import <RestKit/RestKit.h>

#import "CCAddress.h"
#import "CCCategory.h"

@implementation CCNotificationGenerator

- (void)didEnterGeohash:(NSArray *)geohash
{
    NSManagedObjectContext *managedObjectContext = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
    
    NSDate *date = [[NSDate date] dateByAddingTimeInterval:-3600 * 8];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"geohash IN %@ && (lastnotif = nil || lastnotif < %@)", geohash, date];
    [fetchRequest setPredicate:predicate];
    
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    
    if ([results count] == 0) {
        return;
    }
    
    UILocalNotification *localNotification = [UILocalNotification new];
    
    localNotification.alertAction = @"Linotte";
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    
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
    
    if (category == nil)
        localNotification.alertBody = [NSString stringWithFormat:@"Vous êtes proche de %@", address.name];
    else
        localNotification.alertBody = [NSString stringWithFormat:@"Vous êtes proche de %@, %@", address.name, category.name];
    
    localNotification.userInfo = userInfo;
    
    address.lastnotif = [NSDate date];
}

- (void)configureLocalNotificationForAddresses:(NSArray *)addresses localNotification:(UILocalNotification *)localNotification
{
    NSMutableString *alertBody = [NSMutableString stringWithFormat:@"Vous êtes proche de %d adresses:", (int)[addresses count]];
    NSDictionary *userInfo = @{@"multiple" : @(YES)};
    
    for (CCAddress *address in addresses) {
        NSString *sep = @", ";
        
        if (address == [addresses lastObject])
            sep = @" et ";
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
