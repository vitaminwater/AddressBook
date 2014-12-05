//
//  CCPicsMeta.m
//  Linotte
//
//  Created by stant on 27/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCPicsMeta.h"

@implementation CCPicsMeta

- (instancetype)initWithMeta:(id<CCMetaProtocol>)meta
{
    self = [super initWithMeta:meta];
    if (self) {
        
    }
    return self;
}

#pragma mark - CCBaseMetaWidgetProtocol methods

- (void)updateContent
{
    
}

+ (NSString *)action
{
    return @"pics";
}

@end
