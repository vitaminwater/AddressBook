//
//  CCEmailButton.h
//  Linotte
//
//  Created by stant on 06/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCContactButtonProtocol.h"

@interface CCEmailButton : UIButton<CCContactButtonProtocol>

- (instancetype)initWithEmail:(NSString *)email;

@end
