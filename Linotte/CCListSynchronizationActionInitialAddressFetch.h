//
//  CCSynchronizationActionInitialFetch.h
//  Linotte
//
//  Created by stant on 10/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CCSynchronizationActionProtocol.h"

#import "CCModelChangeMonitorDelegate.h"

@class CCList;
@class CCListZone;

void saveNewAddressesInList(CCList *list, NSArray *addressesDicts, NSManagedObjectContext *managedObjectContext);
void initialAddressFetchProcess(CCList *list, CCListZone *zone, NSArray *addressesDicts);

@interface CCListSynchronizationActionInitialAddressFetch : NSObject<CCModelChangeMonitorDelegate, CCSynchronizationActionProtocol>

@end
