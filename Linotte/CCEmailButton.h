//
//  CCEmailButton.h
//  Linotte
//
//  Created by stant on 06/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCFlatColorButton.h"

#import "CCContactButtonProtocol.h"

@interface CCEmailButton : CCFlatColorButton<CCContactButtonProtocol>

- (instancetype)initWithEmail:(NSString *)email;

@end
