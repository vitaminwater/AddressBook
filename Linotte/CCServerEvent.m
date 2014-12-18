#import "CCServerEvent.h"

#import "CCLinotteEngineCoordinator.h"
#import "CCLinotteAPI.h"
#import "CCLinotteCoreDataStack.h"

@interface CCServerEvent ()

@end

@implementation CCServerEvent

+ (CCServerEvent *)insertInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDict:(NSDictionary *)dict
{
    CCServerEvent *serverEvent = [CCServerEvent insertInManagedObjectContext:managedObjectContext];
    serverEvent.date = [CCLEC.linotteAPI dateFromString:dict[@"date"]];
    serverEvent.event = dict[@"event"];
    serverEvent.eventId = dict[@"id"];
    serverEvent.objectIdentifier = dict[@"object_identifier"];
    serverEvent.objectIdentifier2 = dict[@"object_identifier2"];
    return serverEvent;
}

+ (NSArray *)eventsWithEventType:(CCServerEventEvent)event list:(CCList *)list
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CCServerEvent entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"list = %@ and event = %@", list, @(event)];
    [fetchRequest setPredicate:predicate];
    
    NSArray *events = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        CCLog(@"%@", error);
        return @[];
    }
    
    return events;
}

+ (void)deleteEvents:(NSArray *)events
{
    NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
    for (CCServerEvent *event in events) {
        [managedObjectContext deleteObject:event];
    }
    [[CCLinotteCoreDataStack sharedInstance] saveContext];
}

@end
