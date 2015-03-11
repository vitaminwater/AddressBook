//
//  CCTelephoneButton.h
//  Linotte
//
//  Created by stant on 04/12/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCFlatColorButton.h"

#import "CCContactButtonProtocol.h"

@interface CCTelephoneButton : CCFlatColorButton<CCContactButtonProtocol>

- (instancetype)initWithNumber:(NSString *)number;

@end
