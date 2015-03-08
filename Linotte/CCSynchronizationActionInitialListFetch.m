//
//  CCSynchronizationActionInitialListFetch.m
//  Linotte
//
//  Created by stant on 20/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCSynchronizationActionInitialListFetch.h"

#import "CCLinotteAPI.h"
#import "CCLinotteCoreDataStack.h"
#import "CCModelChangeMonitor.h"
#import "CCLinotteEngineCoordinator.h"
#import "CCLinotteAuthenticationManager.h"

#import "CCCurrentUserData.h"
#import "CCList.h"

@implementation CCSynchronizationActionInitialListFetch

- (void)triggerWithList:(CCList *)list coordinates:(CLLocationCoordinate2D)coordinates completionBlock:(CCSynchronizationCompletionBlock)completionBlock
{
    if (list != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(NO, NO);
        });
        return;
    }
    
    NSDate *lastUserEventDate = CCUD.lastUserEventDate;
    
    if (lastUserEventDate != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(NO, NO);
        });
        return;
    }
    
    [CCLEC.linotteAPI fetchInstalledListsWithSuccess:^(NSArray *listsDictArray) {
        NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
        NSArray *lists = [CCList insertOrIgnoreInManagedObjectContext:managedObjectContext fromLinotteAPIDictArray:listsDictArray];
        
        [[CCLinotteCoreDataStack sharedInstance] saveContext];
        
        [[CCModelChangeMonitor sharedInstance] listsDidAdd:lists send:NO];
        
        [CCLEC.linotteAPI fetchUserLastEventDateWithSuccess:^(NSDate *lastEventDate) {
            CCUD.lastUserEventDate = lastEventDate;
            CCUD.lastUserEventUpdate = [NSDate date];
            completionBlock(YES, NO);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            completionBlock(NO, YES);
        }];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completionBlock(NO, YES);
    }];
}

@end
