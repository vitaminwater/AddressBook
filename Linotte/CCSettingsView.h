//
//  CCBaseSettingsView.h
//  Linotte
//
//  Created by stant on 19/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCSettingsViewDelegate.h"

@interface CCSettingsView : UIView

@property(nonatomic, assign)id<CCSettingsViewDelegate> delegate;

- (void)setupContentView:(UIView *)contentView;
- (void)setupLayout;

@end
