//
//  CCOldLinotteMigration.m
//  Linotte
//
//  Created by stant on 12/03/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import "CCOldLinotteMigration.h"

#import "CCLinotteCoreDataStack.h"

#import "SQLiteManager.h"

#import "CCModelHelper.h"

#import "CCList.h"
#import "CCAddress.h"
#import "CCAddressMeta.h"

@implementation CCOldLinotteMigration

+ (void)migrateIfNeeded
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *storeURL = [[[CCLinotteCoreDataStack sharedInstance] applicationDocumentsDirectory] URLByAppendingPathComponent:@"db.sqlite"];

    if ([fileManager fileExistsAtPath:[storeURL path]]) {
        NSManagedObjectContext *managedObjectContext = [CCLinotteCoreDataStack sharedInstance].managedObjectContext;
        SQLiteManager *sqliteManager = [[SQLiteManager alloc] initWithDatabaseNamed:[storeURL path]];
        NSArray *addressesDicts = [sqliteManager getRowsForQuery:@"select * from ZCCADDRESS"];
        for (NSDictionary *addressDict in addressesDicts) {
            NSDictionary *category = [[sqliteManager getRowsForQuery:[NSString stringWithFormat:@"select * from ZCCCATEGORY where ZADDRESS = %@", addressDict[@"Z_PK"]]] firstObject];
            
            
            CCList *list = [CCModelHelper defaultList];
            
            CCAddress *address = [CCAddress insertInManagedObjectContext:managedObjectContext];
            address.name = addressDict[@"ZNAME"];
            address.address = addressDict[@"ZADDRESS"];
            address.geohash = addressDict[@"ZGEOHASH"];
            address.latitudeValue = [addressDict[@"ZLATITUDE"] floatValue];
            address.longitudeValue = [addressDict[@"ZLONGITUDE"] floatValue];
            address.notifyValue = [addressDict[@"ZNOTIFY"] boolValue];
            address.provider = addressDict[@"ZPROVIDER"];
            address.providerId = addressDict[@"ZPROVIDERID"];
            address.isAuthorValue = YES;
            
            [list addAddressesObject:address];
            
            if (category != nil) {
                CCAddressMeta *addressMeta = [CCAddressMeta insertInManagedObjectContext:managedObjectContext];
                addressMeta.uid = @"notification";
                addressMeta.action = @"notification_info";
                addressMeta.content = @{@"name" : category[@"ZNAME"]};
                
                [address addMetasObject:addressMeta];
            }
        }
        [[CCLinotteCoreDataStack sharedInstance] saveContext];
        
        NSError *error = nil;
        [fileManager removeItemAtPath:[storeURL path] error:&error];
        if (error != nil) {
            CCLog(@"%@", error);
        }
    }
}

@end
