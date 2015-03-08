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
#import <FacebookSDK/FacebookSDK.h>

#import "CCLinotteCoreDataStack.h"

#import "CCLinotteEngineCoordinator.h"
#import "CCLinotteAuthenticationManager.h"
#import "CCCurrentUserData.h"

#import "CCRootViewController.h"
#import "CCSignUpViewController.h"
#import "CCOutputViewController.h"

#import "CCAddress.h"
#import "CCListZone.h"
#import "CCLocalEvent.h"

@implementation CCAppDelegate
{
    NSDate *_dateActive;

    UINavigationController *_navigationController;
}

#if defined(DEBUG)

- (void)deleteLocalEvents
{
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCLocalEvent entityName]];
    NSArray *localEvents = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    
    for (CCLocalEvent *localEvent in localEvents) {
        [managedObjectContext deleteObject:localEvent];
    }
    
    [[CCLinotteCoreDataStack sharedInstance] saveContext];
}

- (void)deleteFirstLocalEvent
{
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCLocalEvent entityName]];
    fetchRequest.fetchLimit = 1;
    
    NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    [fetchRequest setSortDescriptors:@[dateSortDescriptor]];
    
    NSArray *localEvents = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    
    [managedObjectContext deleteObject:[localEvents firstObject]];
    
    [[CCLinotteCoreDataStack sharedInstance] saveContext];
}

- (void)generateFakeNotifications
{
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
    fetchRequest.fetchLimit = 10;
    
    NSArray *addresses = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    
    for (CCAddress *address in addresses) {
        address.lastnotif = [[NSDate date] dateByAddingTimeInterval:-(3600 * rand() % 100)];
    }
    
    [[CCLinotteCoreDataStack sharedInstance] saveContext];
}

- (void)clearCredentials
{
    [CCLEC.authenticationManager logout];
}

- (void)dumpZones
{
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCListZone entityName]];
    
    NSArray *zones = [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    
    for (CCListZone *zone in zones) {
        NSLog(@"%@ %@ %@ %@ %@", zone.geohash, zone.nAddresses, zone.needsMerge, zone.readyToMerge, zone.firstFetch);
    }
}

#endif

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self initAll:application];
    
    //[self deleteLocalEvents];
    //[self deleteFirstLocalEvent];
    //[self generateFakeNotifications];
    //[self clearCredentials];
    //[self dumpZones];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UIViewController *rootViewController = nil;
    if ([CCLEC.authenticationManager needsCredentials]) {
        rootViewController = [CCSignUpViewController new];
        ((CCSignUpViewController *)rootViewController).delegate = self;
    } else {
        rootViewController = [CCRootViewController new];
    }
    
    _navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    self.window.rootViewController = _navigationController;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    if (application.applicationState == UIApplicationStateInactive) {
        UILocalNotification *notification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
        [self processNotification:notification];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[Mixpanel sharedInstance] track:@"Active time" properties:@{@"time": @([[NSDate date] timeIntervalSinceDate:_dateActive])}];
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
    _dateActive = [NSDate date];
    [[Mixpanel sharedInstance] track:@"Application active" properties:@{@"date": [NSDate date]}];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [FBAppCall handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [[CCLinotteCoreDataStack sharedInstance] saveContext];
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    CCLog(@"Background fetch called");
    [CCLEC application:application performFetchWithCompletionHandler:completionHandler];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    // You can add your app-specific url handling code here if needed
    
    return wasHandled;
}

#pragma mark - RestKit initialization

- (void)initAll:(UIApplication *)application
{
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [application registerForRemoteNotifications];
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil]];
    } else {
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeNewsstandContentAvailability];
    }
    
    // Facebook SDK
    [FBAppEvents activateApp];
    
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
    
    
    
    {
#if defined(DEBUG)
        NSString *clientId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"linotte_api_client_debug"];
        NSString *clientSecret = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"linotte_api_secret_debug"];
#else
        NSString *clientId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"linotte_api_client"];
        NSString *clientSecret = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"linotte_api_secret"];
#endif
        [CCLEC initializeLinotteEngineWithClientId:clientId clientSecret:clientSecret];
        
        if (CCLEC.authenticationManager.deviceId != nil) {
            [CCNetworkLogs sharedInstance].identifier = CCLEC.authenticationManager.deviceId;
        }
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    if (CCUD.pushNotificationDeviceToken == nil || ![CCUD.pushNotificationDeviceToken isEqualToData:deviceToken]) {
        CCUD.pushNotificationDeviceToken = deviceToken;
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if (application.applicationState == UIApplicationStateInactive)
        [self processNotification:notification];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler
{
    if (application.applicationState == UIApplicationStateInactive)
        [self processNotification:notification];
    completionHandler();
}

#pragma mark -

- (void)processNotification:(UILocalNotification *)notification
{
    if (notification == nil)
        return;
    
    if ([notification.userInfo[@"multiple"] isEqualToNumber:@YES]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kCCShowNotificationPanelNotification object:nil];
        return;
    }
    
    NSError *error = nil;
    NSString *objectID = notification.userInfo[@"addressLocalIdentifier"];
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCAddress entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"localIdentifier = %@", objectID];
    [fetchRequest setPredicate:predicate];
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        CCLog(@"%@", error);
    }
    
    if ([results count]) {
        CCAddress *address = [results firstObject];
        CCOutputViewController *outPutViewController = [[CCOutputViewController alloc] initWithAddress:address];
        [((UINavigationController *)self.window.rootViewController) pushViewController:outPutViewController animated:YES];
        NSString *identifier = address.identifier ?: @"NEW";
        @try {
            [[Mixpanel sharedInstance] track:@"Local notification handled" properties:@{@"name": address.name, @"address": address.address, @"identifier": identifier}];
        }
        @catch(NSException *e) {
            CCLog(@"%@", e);
        }
    }
}

#pragma mark - CCSignUpViewControllerDelegate

- (void)signupCompleted
{
    [_navigationController setViewControllers:@[[CCRootViewController new]] animated:YES];
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)applicationLibraryDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
