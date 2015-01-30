//
//  CCMetaButtonsView.h
//  Linotte
//
//  Created by stant on 29/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCActionButtonsView : UIView

- (instancetype)initWithActionViewParent:(UIView *)actionViewParent;
- (void)addActionWithView:(UIView *)actionView fullWidth:(BOOL)fullWidth minHeight:(CGFloat)minHeight icon:(UIImage *)icon;
- (void)setupLayout;
- (void)removeActionView;

@end
