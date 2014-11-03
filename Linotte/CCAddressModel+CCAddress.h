//
//  CCAddressModel+CCAddress.h
//  Linotte
//
//  Created by stant on 02/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCLinotteAPI.h"

@interface CCAddressModel (CCAddress)

- (CCAddress *)toInsertedCCAddressZoneInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
