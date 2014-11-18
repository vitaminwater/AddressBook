//
//  CCSynchronizationActionConsumeEvents.m
//  Linotte
//
//  Created by stant on 10/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCBaseSynchronizationActionConsumeEvents.h"

#import "CCCoreDataStack.h"

#import "CCLinotteAPI.h"

#import "CCServerEventConsumerProtocol.h"

#import "CCList.h"
#import "CCListZone.h"
#import "CCServerEvent.h"

@implementation CCBaseSynchronizationActionConsumeEvents
{
    __weak id<CCSynchronizationActionConsumeEventsProviderProtocol> _provider;
}

- (instancetype)initWithProvider:(id<CCSynchronizationActionConsumeEventsProviderProtocol>)provider
{
    self = [super init];
    if (self) {
        _provider = provider;
    }
    return self;
}

- (void)triggerWithList:(CCList *)list coordinates:(CLLocationCoordinate2D)coordinates completionBlock:(void(^)(BOOL goOnSyncing))completionBlock
{
    list = list ?: [_provider findNextListToProcess];
    if (list == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(NO);
        });
        return;
    }
    
    CCLog(@"Starting %@ job", NSStringFromClass([self class]));
    
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCServerEvent entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"list = %@ and event in %@", list, [_provider eventsList]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSUInteger eventCount = [managedObjectContext countForFetchRequest:fetchRequest error:&error];
    if (error != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(NO);
        });
        CCLog(@"%@", error);
        return;
    }
    
    if (eventCount == 0) {
        [_provider fetchServerEventsWithList:list completionBlock:^(BOOL goOnSyncing){
            completionBlock(goOnSyncing);
        }];
        return;
    }
    
    for (id<CCServerEventConsumerProtocol> consumer in [_provider consumers]) {
        if ([consumer hasEventsForList:list]) {
            CCLog(@"Triggering event consumer: %@", NSStringFromClass([consumer class]));
            [consumer triggerWithList:list completionBlock:^(BOOL goOnSyncing){
                completionBlock(goOnSyncing);
            }];
            return;
        }
    }
    completionBlock(NO);
}

@end
