//
//  CCFacebookOverlayViewController.h
//  Linotte
//
//  Created by stant on 08/12/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <FacebookSDK/FacebookSDK.h>

#import "CCSignUpViewDelegate.h"
#import "CCSignUpViewControllerDelegate.h"

@interface CCSignUpViewController : UIViewController<CCSignUpViewDelegate, FBLoginViewDelegate>

@property(nonatomic, weak)id<CCSignUpViewControllerDelegate> delegate;

@end
