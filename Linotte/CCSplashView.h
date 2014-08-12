//
//  CCSplashView.h
//  Linotte
//
//  Created by stant on 10/08/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCSplashViewDelegate.h"

@interface CCSplashView : UIView

@property(nonatomic, assign)id<CCSplashViewDelegate> delegate;

@end
