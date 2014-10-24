#import "CCAddress.h"


@interface CCAddress ()

@end

@implementation CCAddress

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.notificationId = [[NSUUID UUID] UUIDString];
}

@end
