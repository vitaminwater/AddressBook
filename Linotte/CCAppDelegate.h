//
//  CCAppDelegate.h
//  Linotte
//
//  Created by stant on 06/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCSignUpViewControllerDelegate.h"

@interface CCAppDelegate : UIResponder <UIApplicationDelegate, CCSignUpViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

- (NSURL *)applicationDocumentsDirectory;
- (NSURL *)applicationLibraryDirectory;

@end
