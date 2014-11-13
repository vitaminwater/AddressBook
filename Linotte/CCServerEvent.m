#import "CCServerEvent.h"

#import "CCLinotteAPI.h"

@interface CCServerEvent ()

@end

@implementation CCServerEvent

+ (CCServerEvent *)insertInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDict:(NSDictionary *)dict
{
    CCServerEvent *serverEvent = [CCServerEvent insertInManagedObjectContext:managedObjectContext];
    serverEvent.date = [[CCLinotteAPI sharedInstance] dateFromString:dict[@"date"]];
    serverEvent.event = dict[@"event"];
    serverEvent.eventId = dict[@"id"];
    serverEvent.objectIdentifier = dict[@"object_identifier"];
    serverEvent.objectIdentifier2 = dict[@"object_identifier2"];
    return serverEvent;
}

@end
