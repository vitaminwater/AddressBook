//
//  CCAddressModel+CCAddress.m
//  Linotte
//
//  Created by stant on 02/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCAddressModel+CCAddress.h"

#import "CCGeohashHelper.h"

#import "CCAddress.h"

@implementation CCAddressModel (CCAddress)

- (CCAddress *)toInsertedCCAddressZoneInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    CCAddress *address = [CCAddress insertInManagedObjectContext:managedObjectContext];
    address.identifier = self.identifier;
    address.latitude = self.latitude;
    address.longitude = self.longitude;
    address.geohash = [CCGeohashHelper geohashFromCoordinates:CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue])];
    address.name = self.name;
    address.address = self.address;
    address.provider = self.provider;
    address.providerId = self.providerId;
    address.note = self.note;
    address.notify = self.notification;
    return address;
}

@end
