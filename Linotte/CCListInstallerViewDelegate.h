//
//  CCListInstallerViewDelegate.h
//  Linotte
//
//  Created by stant on 26/10/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCListInstallerViewDelegate <NSObject>

- (void)addToLinotteButtonPressed;
- (void)removeToLinotteButtonPressed;
- (void)closeButtonPressed;

@end
