//
//  CCCompleteListInfoModel+CCList.m
//  Linotte
//
//  Created by stant on 29/10/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCCompleteListInfoModel+CCList.h"

#import "CCList.h"

@implementation CCCompleteListInfoModel (CCList)

- (CCList *)toInsertedCCListInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    CCList *list = [CCList insertInManagedObjectContext:managedObjectContext];
    list.identifier = self.identifier;
    list.name = self.name;
    list.icon = self.icon;
    list.provider = self.author;
    list.providerId = self.authorId;
    list.owned = @(NO);
    return list;
}

@end
