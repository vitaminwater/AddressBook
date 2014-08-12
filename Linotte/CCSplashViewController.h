//
//  CCSplashViewController.h
//  Linotte
//
//  Created by stant on 10/08/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCSplashViewDelegate.h"
#import "CCSplashViewControllerDelegate.h"

@interface CCSplashViewController : UIViewController<CCSplashViewDelegate>

@property(nonatomic, assign)id<CCSplashViewControllerDelegate> delegate;

@end
