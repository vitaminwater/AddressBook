//
//  CCFirstDisplayListSettingsView.h
//  Linotte
//
//  Created by stant on 19/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCFirstListDisplaySettingsViewDelegate.h"

@interface CCFirstListDisplaySettingsView : UIView

@property(nonatomic, assign)id<CCFirstListDisplaySettingsViewDelegate> delegate;

@end
