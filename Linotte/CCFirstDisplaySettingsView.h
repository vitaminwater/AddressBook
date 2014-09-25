//
//  CCFirstDisplaySettingsView.h
//  Linotte
//
//  Created by stant on 19/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCFirstDisplaySettingsViewDelegate.h"

@interface CCFirstDisplaySettingsView : UIView

@property(nonatomic, assign)id<CCFirstDisplaySettingsViewDelegate> delegate;

@end
