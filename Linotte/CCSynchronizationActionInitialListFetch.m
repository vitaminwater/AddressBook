//
//  CCSynchronizationActionInitialListFetch.m
//  Linotte
//
//  Created by stant on 20/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCSynchronizationActionInitialListFetch.h"

#import "CCLinotteAPI.h"
#import "CCCoreDataStack.h"
#import "CCModelChangeMonitor.h"

#import "CCUserDefaults.h"
#import "CCList.h"

@implementation CCSynchronizationActionInitialListFetch

- (void)triggerWithList:(CCList *)list coordinates:(CLLocationCoordinate2D)coordinates completionBlock:(void(^)(BOOL goOnSyncing, BOOL error))completionBlock
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
    
    [[CCLinotteAPI sharedInstance] fetchInstalledListsWithCompletionBlock:^(BOOL success, NSArray *listsDictArray) {
        
        if (success == NO) {
            completionBlock(NO, YES);
            return;
        }
        
        NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
        NSArray *lists = [CCList insertOrIgnoreInManagedObjectContext:managedObjectContext fromLinotteAPIDictArray:listsDictArray];
        
        for (CCList *list in lists) {
            list.ownedValue = [list.authorIdentifier isEqualToString:[CCLinotteAPI sharedInstance].identifier];
        }
        
        [[CCCoreDataStack sharedInstance] saveContext];
        
        [[CCModelChangeMonitor sharedInstance] listsDidAdd:lists send:NO];
        
        [[CCLinotteAPI sharedInstance] fetchUserLastEventDateWithCompletionBlock:^(BOOL success, NSDate *lastEventDate) {
            if (success == NO) {
                completionBlock(NO, YES);
                return;
            }
            CCUD.lastUserEventDate = lastEventDate;
            completionBlock(YES, NO);
        }];
    }];
}

@end
