//
//  CCAddListCommand.m
//  Linotte
//
//  Created by stant on 12/03/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import "CCAddListCommand.h"

#import "CCLinotteCoreDataStack.h"

#import "CCLinotteEngineCoordinator.h"
#import "CCLinotteAPI.h"
#import "CCModelChangeMonitor.h"

#import "CCList.h"

@implementation CCAddListCommand

@synthesize match = _match;

- (id)init
{
    self = [super init];
    if (self) {
        _match = @"^list/add/([^/]+)/";
    }
    return self;
}

#pragma mark - CCLinotteUrlCommand methods

- (void)execute:(NSArray *)params
{
    if ([params count] <= 3)
        return;
    
    params = [params subarrayWithRange:(NSRange){2, [params count] - 2}];
    
    NSString *identifier = params[0];
    
    [CCLEC.linotteAPI fetchCompleteListInfos:identifier success:^(NSDictionary *listInfo) {
        NSManagedObjectContext *managedObjectContext = [[CCLinotteCoreDataStack sharedInstance] managedObjectContext];
        CCList *list = [CCList insertOrUpdateInManagedObjectContext:managedObjectContext fromLinotteAPIDict:listInfo];
        list.identifier = identifier;
        [[CCLinotteCoreDataStack sharedInstance] saveContext];
        
        [[CCModelChangeMonitor sharedInstance] listsDidAdd:@[list] send:YES];
        [CCLEC forceListSynchronization:list];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kCCShowListOutputNotification object:list];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        CCLog(@"%@", error);
    }];
}

@end
