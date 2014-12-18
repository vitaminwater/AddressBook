//
//  CCLinotteAuthenticationManagerDelegate.h
//  Linotte
//
//  Created by stant on 17/12/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCLinotteAuthenticationManager;
@class CCLinotteCredentialStore;

@protocol CCLinotteAuthenticationManagerDelegate <NSObject>

- (void)authenticationManager:(CCLinotteAuthenticationManager *)authenticationManager didCreateUserWithEmail:(NSString *)email identifier:(NSString *)identifier;
- (void)authenticationManagerDidLogin:(CCLinotteAuthenticationManager *)authenticationManager;

@end
