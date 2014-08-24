//
//  CCAppDelegate.m
//  Linotte
//
//  Created by stant on 06/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCAppDelegate.h"

#import <GoogleMaps/GoogleMaps.h>
#import <Mixpanel/Mixpanel.h>

#import "CCNotificationGenerator.h"

#import "CCLocalAPI.h"

#import "CCNetworkHandler.h"

#import "CCGeohashMonitor.h"
#import "CCNotificationGenerator.h"

#import "CCMainViewController.h"
#import "CCOutputViewController.h"

#import "CCRestKit.h"

@interface CCAppDelegate()

@property(nonatomic, strong)NSDate *dateActive;

@end

@implementation CCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self initAll];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    CCMainViewController *rootViewController = [CCMainViewController new];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    self.window.rootViewController = navigationController;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    if (application.applicationState != UIApplicationStateBackground) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        
        UILocalNotification *notification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
        [self processNotification:notification];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[Mixpanel sharedInstance] track:@"Active time" properties:@{@"time": @([[NSDate date] timeIntervalSinceDate:self.dateActive] / 60)}];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    self.dateActive = [NSDate date];
    [[Mixpanel sharedInstance] track:@"Application launch" properties:@{@"date": [NSDate date]}];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
}

#pragma mark - RestKit initialization

- (void)initAll
{
    [self initRestkitCoreDataStack];
    [self initRestKitMappings];
    
    // Google map service initialization
    [GMSServices provideAPIKey:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"google_map_api_key"]];
    
    // MixPanel service initialization
    {
    #if defined(DEBUG)
        NSString *token = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"mixpanel_api_token_debug"];
    #else
        NSString *token = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"mixpanel_api_token"];
    #endif
        
        [Mixpanel sharedInstanceWithToken:token];
    }
    
    // Linotte API initialization
    {
    #if defined(DEBUG)
        NSString *clientId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"linotte_api_client_debug"];
        NSString *secret = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"linotte_api_secret_debug"];
    #else
        NSString *clientId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"linotte_api_client"];
        NSString *secret = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"linotte_api_secret"];
    #endif
        [[CCLocalAPI sharedInstance] setClientId:clientId clientSecret:secret];
    }
    
    //[CCNotificationGenerator printLastNotif];
    //[CCNotificationGenerator resetLastNotif];
    
    [CCGeohashMonitor sharedInstance].delegate = [CCNotificationGenerator sharedInstance];
    
    [CCNetworkHandler sharedInstance];
}

- (void)initRestkitCoreDataStack
{
    NSError *error = nil;
    NSURL *modelURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Linotte" ofType:@"momd"]];
    // NOTE: Due to an iOS 5 bug, the managed object model returned is immutable.
    NSManagedObjectModel *managedObjectModel = [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] mutableCopy];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    
    // Initialize the Core Data stack
    [managedObjectStore createPersistentStoreCoordinator];
    
    NSString *sqlitePath = [CCRestKit storePath];
    
    NSPersistentStore __unused *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:sqlitePath
                                                                              fromSeedDatabaseAtPath:nil
                                                                                   withConfiguration:nil
                                                                                             options:nil
                                                                                               error:&error];
    NSAssert(persistentStore, @"Failed to add persistent store: %@", error);
    
    [managedObjectStore createManagedObjectContexts];
    
    // Set the default store shared instance
    [RKManagedObjectStore setDefaultStore:managedObjectStore];
}

- (void)initRestKitMappings
{
    [CCRestKit initializeMappings];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    //[self processNotification:notification];
}

#pragma mark -

- (void)processNotification:(UILocalNotification *)notification
{
    if (notification == nil)
        return;
    
    if ([notification.userInfo[@"multiple"] isEqualToNumber:@YES]) {
        NSLog(@"multiple");
        return;
    }
    
    NSString *objectID = notification.userInfo[@"addressId"];
    NSManagedObjectContext *managedObjectContext = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier = %@", objectID];
    [fetchRequest setPredicate:predicate];
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    if ([results count]) {
        CCAddress *address = [results firstObject];
        CCOutputViewController *outPutViewController = [[CCOutputViewController alloc] initWithAddress:address];
        [((UINavigationController *)self.window.rootViewController) pushViewController:outPutViewController animated:YES];
        [[Mixpanel sharedInstance] track:@"Local notification handled" properties:@{@"name": address.name, @"address": address.address, @"identifier": address.identifier}];
    }
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
