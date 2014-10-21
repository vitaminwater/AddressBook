//
//  CCListOutputExpandedSettingsView.h
//  Linotte
//
//  Created by stant on 28/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCListOutputSettingsViewDelegate.h"
#import "CCListOutputListEmptyViewDelegate.h"

@interface CCListOutputSettingsView : UIView<CCListOutputListEmptyViewDelegate>

@property(nonatomic, weak)id<CCListOutputSettingsViewDelegate> delegate;

@end
