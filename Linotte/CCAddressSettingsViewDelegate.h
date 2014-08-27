//
//  CCAddressSettingsViewDelegate.h
//  Linotte
//
//  Created by stant on 25/08/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCAddressSettingsViewDelegate <NSObject>

- (void)closeButtonPressed:(id)sender;
- (void)setNotificationEnabled:(BOOL)enabled;

@end
