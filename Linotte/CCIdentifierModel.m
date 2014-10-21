//
//  CCIdentifierModel.m
//  Linotte
//
//  Created by stant on 04/10/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCIdentifierModel.h"

@implementation CCIdentifierModel

- (instancetype)initWithIdentifier:(NSString *)identifier
{
    self = [super init];
    if (self) {
        _identifier = identifier;
    }
    return self;
}

@end
