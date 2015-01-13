//
//  CCActionResultHUD.h
//  Linotte
//
//  Created by stant on 25/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCActionResultHUD : UIView

+ (CCActionResultHUD *)showActionResultWithImage:(UIImage *)image inView:(UIView *)view text:(NSString *)text delay:(NSTimeInterval)delay;
+ (void)removeActionResult:(CCActionResultHUD *)actionResultHUD;
+ (UIView *)applicationRootView;

@end
