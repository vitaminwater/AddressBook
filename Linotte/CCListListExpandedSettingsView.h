//
//  CCListOutputExpandedSettingsView.h
//  Linotte
//
//  Created by stant on 28/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCListListExpandedSettingsViewDelegate.h"

@interface CCListListExpandedSettingsView : UIView<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, weak)id<CCListListExpandedSettingsViewDelegate> delegate;

@end
