//
//  UIView+CCShowSettingsView.h
//  Linotte
//
//  Created by stant on 19/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CCShowSettingsView)

- (void)showSettingsView:(UIView *)settingsView fullScreen:(BOOL)fullScreen;
- (void)hideSettingsView:(UIView *)settingsView;

@end
