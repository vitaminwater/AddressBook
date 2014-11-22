//
//  NSArray+CCArray.m
//  Linotte
//
//  Created by stant on 21/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "NSArray+CCArray.h"

@implementation NSArray (CCArray)

- (NSArray *)arrayByRemovingObjectsFromArray:(NSArray *)otherArray
{
    if (otherArray == nil || [otherArray count] == 0)
        return [self copy];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT SELF IN %@", otherArray];
    return [self filteredArrayUsingPredicate:predicate];
}

@end
