//
//  CCServerEventConsumerUtils.m
//  Linotte
//
//  Created by stant on 12/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCServerEventConsumerUtils.h"

#import "CCCoreDataStack.h"

@implementation CCServerEventConsumerUtils

+ (NSArray *)eventsWithEventType:(CCServerEventEvent)event list:(CCList *)list
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCServerEvent entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"list = %@", list];
    [fetchRequest setPredicate:predicate];

    return [managedObjectContext executeFetchRequest:fetchRequest error:NULL];
}

+ (void)deleteEvents:(NSArray *)events
{
    NSManagedObjectContext *managedObjectContext = [CCCoreDataStack sharedInstance].managedObjectContext;
    for (CCServerEvent *event in events) {
        [managedObjectContext deleteObject:event];
    }
    [[CCCoreDataStack sharedInstance] saveContext];
}

@end
