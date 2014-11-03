//
//  CCListGeohashZone+CCListZone.h
//  Linotte
//
//  Created by stant on 29/10/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCLinotteAPI.h"

@class CCListZone;

@interface CCListGeohashZoneModel (CCListZone)

- (CCListZone *)toInsertedCCListZoneInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
