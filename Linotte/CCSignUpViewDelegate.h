//
//  CCSignUpViewDelegate.h
//  Linotte
//
//  Created by stant on 08/12/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCSignUpViewDelegate <NSObject>

- (void)loginSignupButtonPressed:(NSString *)email password:(NSString *)password;

@end
