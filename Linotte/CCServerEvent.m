#import "CCServerEvent.h"

@interface CCServerEvent ()

@end

@implementation CCServerEvent

+ (CCServerEvent *)insertInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromLinotteAPIDict:(NSDictionary *)dict
{
    CCServerEvent *serverEvent = [CCServerEvent insertInManagedObjectContext:managedObjectContext];
    serverEvent.id = dict[@"id"];
    serverEvent.event = dict[@"event"];
    serverEvent.objectIdentifier = dict[@"object_identifier"];
    return serverEvent;
}

@end
