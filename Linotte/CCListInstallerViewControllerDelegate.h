//
//  CCListInstallerViewControllerDelegate.h
//  Linotte
//
//  Created by stant on 26/10/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCListInstallerViewController;
@class CCList;

@protocol CCListInstallerViewControllerDelegate <NSObject>

- (void)closeListInstaller:(CCListInstallerViewController *)sender;
- (void)listInstaller:(CCListInstallerViewController *)sender listInstalled:(CCList *)list;

@end
