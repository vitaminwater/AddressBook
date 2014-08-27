//
//  CCAddressSettingsView.h
//  Linotte
//
//  Created by stant on 25/08/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCAddressSettingsViewDelegate.h"

@interface CCAddressSettingsView : UIView

@property(nonatomic, assign)id<CCAddressSettingsViewDelegate> delegate;

@property(nonatomic, assign)BOOL notificationEnabled;

@end
