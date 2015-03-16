//
//  CCFacebookOverlayView.h
//  Linotte
//
//  Created by stant on 08/12/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCSignUpViewDelegate.h"

@interface CCSignUpView : UIView

@property(nonatomic, assign)BOOL reachable;
@property(nonatomic, weak)id<CCSignUpViewDelegate> delegate;
@property(nonatomic, readonly)BOOL loading;

- (void)showLoadingView;
- (void)hideLoadingView;

@end
