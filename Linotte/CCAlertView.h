//
//  CCAlertView.h
//  Linotte
//
//  Created by stant on 25/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCAlertView : UIView

@property(nonatomic, strong)id userInfo;

+ (instancetype)showAlertViewWithText:(NSString *)text target:(id)target okAction:(SEL)okAction cancelAction:(SEL)cancelAction;
+ (void)closeAlertView:(CCAlertView *)alertView;

@end
