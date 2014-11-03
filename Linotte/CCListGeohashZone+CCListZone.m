//
//  CCListGeohashZone+CCListZone.m
//  Linotte
//
//  Created by stant on 29/10/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListGeohashZone+CCListZone.h"

#import "CCGeohashHelper.h"

#import "CCListZone.h"

@implementation CCListGeohashZoneModel (CCListZone)

- (CCListZone *)toInsertedCCListZoneInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    CCListZone *listZone = [CCListZone insertInManagedObjectContext:managedObjectContext];
    CLLocationCoordinate2D coordinates = [CCGeohashHelper coordinatesFromGeohash:self.geohash];
    listZone.geohash = self.geohash;
    listZone.latitudeValue = coordinates.latitude;
    listZone.longitudeValue = coordinates.longitude;
    listZone.nAddresses = self.nAddresses;
    return listZone;
}

@end