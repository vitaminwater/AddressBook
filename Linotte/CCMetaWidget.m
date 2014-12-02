//
//  CCBaseMetaWidget.m
//  Linotte
//
//  Created by stant on 27/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCMetaWidget.h"

#import "CCDisplayMeta.h"
#import "CCWebLinkMeta.h"
#import "CCTelMeta.h"
#import "CCPicsMeta.h"
#import "CCOpenHoursMeta.h"

@implementation CCMetaWidget

- (instancetype)initWithMeta:(id<CCMetaProtocol>)meta
{
    self = [super init];
    if (self) {
        _meta = meta;
    }
    return self;
}

- (void)updateContent {}

+ (NSString *)action {return nil;}

+ (CCMetaWidget *)widgetForMeta:(id<CCMetaProtocol>)meta
{
    static NSArray *widgets = nil;
    
    if (widgets == nil) {
        widgets = @[[CCDisplayMeta class], [CCWebLinkMeta class], [CCTelMeta class], [CCPicsMeta class], [CCOpenHoursMeta class]];
    }
    
    for (Class metaClass in widgets) {
        NSString *action = [metaClass action];
        
        if ([meta.action isEqualToString:action])
            return [[metaClass alloc] initWithMeta:meta];
    }
    
    return nil;
}

@end
