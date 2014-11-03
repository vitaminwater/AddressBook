//
//  CCCompleteListInfoModel+CCList.h
//  Linotte
//
//  Created by stant on 29/10/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCLinotteAPI.h"

@class CCList;

@interface CCCompleteListInfoModel (CCList)

- (CCList *)toInsertedCCListInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
