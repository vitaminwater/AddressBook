//
//  NSString+CCMultiReplace.m
//  Linotte
//
//  Created by stant on 03/06/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "NSString+CCLocalizedString.h"

@implementation NSString (CCLocalizedString)

+ (NSString *)localizedStringByReplacingFromDictionnary:(NSDictionary *)replaceDictionnary localizedKey:(NSString *)localizedKey
{
    NSString *result = NSLocalizedString(localizedKey, @"");
    for (NSString *key in replaceDictionnary.allKeys) {
        NSString *value = replaceDictionnary[key];
        
        result = [result stringByReplacingOccurrencesOfString:key withString:value];
    }
    return result;
}

@end