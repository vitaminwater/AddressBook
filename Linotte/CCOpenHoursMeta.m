//
//  CCOpenHoursMeta.m
//  Linotte
//
//  Created by stant on 27/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCOpenHoursMeta.h"

#import "CCLinotteAPI.h"

@implementation CCOpenHoursMeta
{

}

- (instancetype)initWithMeta:(id<CCMetaProtocol>)meta
{
    self = [super initWithMeta:meta];
    if (self) {
        [self setupDates];
    }
    return self;
}

- (void)setupDates
{
}

#pragma mark - CCBaseMetaWidgetProtocol methods

- (void)updateContent
{
}

+ (NSString *)action
{
    return @"open_hours";
}

@end
