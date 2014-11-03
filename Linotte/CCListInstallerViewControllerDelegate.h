//
//  CCListInstallerViewControllerDelegate.h
//  Linotte
//
//  Created by stant on 26/10/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCListInstallerViewController;

@protocol CCListInstallerViewControllerDelegate <NSObject>

- (void)closeListInstaller:(CCListInstallerViewController *)sender;

@end
