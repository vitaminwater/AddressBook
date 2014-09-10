//
//  CCAddressSettingsView.h
//  Linotte
//
//  Created by stant on 25/08/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCSettingsViewDelegate.h"

@interface CCSettingsView : UIView

@property(nonatomic, assign)id<CCSettingsViewDelegate> delegate;

@property(nonatomic, assign)BOOL notificationEnabled;
@property(nonatomic, strong)NSString *listNames;

@end
