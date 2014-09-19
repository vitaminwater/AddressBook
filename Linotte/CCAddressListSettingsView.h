//
//  CCListSettingsView.h
//  Linotte
//
//  Created by stant on 06/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCAddressListSettingsViewDelegate.h"

@interface CCAddressListSettingsView : UIView<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>

@property(nonatomic, assign)id<CCAddressListSettingsViewDelegate> delegate;

@end
