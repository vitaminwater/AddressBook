//
//  CCLastNotifListViewContentProvider.m
//  Linotte
//
//  Created by stant on 25/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCLastNotifListViewContentProvider.h"

#import "CCAddress.h"

@implementation CCLastNotifListViewContentProvider
{
    NSDateFormatter *_dateFormatter;
}

- (instancetype)initWithModel:(CCListViewModel<CCListViewModelProtocol> *)model
{
    self = [super initWithModel:model];
    if (self) {
        _dateFormatter = [NSDateFormatter new];
        [_dateFormatter setLocale:[NSLocale currentLocale]];
        [_dateFormatter setDateFormat:NSLocalizedString(@"SHORT_DATE_FORMAT", @"")];
    }
    return self;
}

- (NSString *)infoForListItemAtIndex:(NSUInteger)index
{
    CCAddress *address = (CCAddress *)[self listItemContentAtIndex:index];
    
    NSString *lastNotifString = [_dateFormatter stringFromDate:address.lastnotif];
    
    return [NSString stringWithFormat:@"%@:\n%@", NSLocalizedString(@"LAST_SEEN", @""), lastNotifString];
}

- (NSComparisonResult(^)(CCListItem *obj1, CCListItem *obj2))sortBlock
{
    return ^NSComparisonResult(CCListItem *obj1, CCListItem *obj2) {
        CCAddress *address1 = ((CCListItemAddress *)obj1).address;
        CCAddress *address2 = ((CCListItemAddress *)obj2).address;
        
        return -[address1.lastnotif compare:address2.lastnotif];
    };
}

@end
