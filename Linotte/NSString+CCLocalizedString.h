//
//  NSString+CCMultiReplace.h
//  Linotte
//
//  Created by stant on 03/06/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CCLocalizedString)

+ (NSString *)localizedStringByReplacingFromDictionnary:(NSDictionary *)replaceDictionnary localizedKey:(NSString *)localizedKey;

@end
