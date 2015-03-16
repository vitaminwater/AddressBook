//
//  CCEmailLoginView.h
//  Linotte
//
//  Created by stant on 08/12/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCSignUpViewDelegate.h"

@interface CCEmailLoginView : UIView<UITextFieldDelegate>

@property(nonatomic, assign)BOOL reachable;

@property(nonatomic, weak)id<CCSignUpViewDelegate> delegate;

@end
