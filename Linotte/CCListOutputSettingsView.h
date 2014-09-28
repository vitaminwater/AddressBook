//
//  CCListOutputExpandedSettingsView.h
//  Linotte
//
//  Created by stant on 28/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCListOutputSettingsViewDelegate.h"

@interface CCListOutputSettingsView : UIView

@property(nonatomic, weak)id<CCListOutputSettingsViewDelegate> delegate;

@end
