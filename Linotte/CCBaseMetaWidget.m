//
//  CCBaseMetaWidget.m
//  Linotte
//
//  Created by stant on 27/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCBaseMetaWidget.h"

#import "CCBaseMetaWidgetProtocol.h"

#import "CCDisplayMeta.h"
#import "CCExternalMeta.h"
#import "CCSocialMeta.h"
#import "CCPhotoMeta.h"
#import "CCOpenHoursMeta.h"

@implementation CCBaseMetaWidget

- (instancetype)initWithMeta:(id<CCMetaProtocol>)meta
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

        _isValid = YES;
        if (![[self class] conformsToProtocol:@protocol(CCBaseMetaWidgetProtocol)]) {
            @throw [NSException exceptionWithName:@"implementation error" reason:@"CCBaseMetaWidgetProtocol not implemented" userInfo:nil];
        }
        
        _meta = meta;
    }
    return self;
}

+ (CCBaseMetaWidget *)widgetForMeta:(id<CCMetaProtocol>)meta
{
    static NSArray *widgets = nil;
    
    if (widgets == nil) {
        widgets = @[[CCDisplayMeta class], [CCExternalMeta class], [CCSocialMeta class], [CCPhotoMeta class], [CCOpenHoursMeta class]];
    }
    
    for (Class metaClass in widgets) {
        NSString *action = [metaClass action];
        
        if ([meta.action isEqualToString:action]) {
            CCBaseMetaWidget *metaWidget = [[metaClass alloc] initWithMeta:meta];
            if (metaWidget.isValid)
                return metaWidget;
            else
                return nil;
        }
    }
    
    return nil;
}

@end
