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

@implementation CCNotificationGenerator

- (void)didEnterGeohash:(NSString *)geohash
{
    NSManagedObjectContext *managedObjectContext = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
    
    NSDate *date = [[NSDate date] dateByAddingTimeInterval:-3600 * 24];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"geohash = %@ && (lastnotif = nil || lastnotif < %@)", geohash, date];
    [fetchRequest setPredicate:predicate];
    
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    
    for (CCAddress *address in results) {
        NSDictionary *userInfo = @{@"addressId" : address.identifier};
        UILocalNotification *localNotification = [UILocalNotification new];
        localNotification.alertBody = [NSString stringWithFormat:@"%@ %@", address.name, address.address];
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.userInfo = userInfo;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        
        address.lastnotif = [NSDate date];
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = [results count];
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
