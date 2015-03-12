//
//  NSFileManager+CCNoiCloudBackup.m
//  Linotte
//
//  Created by stant on 11/03/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import "NSFileManager+CCNoiCloudBackup.h"

@implementation NSFileManager (CCNoiCloudBackup)

+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

@end
