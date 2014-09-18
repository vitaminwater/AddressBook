//
//  CCAddView.h
//  Linotte
//
//  Created by stant on 06/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCAddAddressViewDelegate.h"

@interface CCAddAddressView : UIView<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, weak)id<CCAddAddressViewDelegate> delegate;

- (void)reloadAutocompletionResults;

- (void)enableField;
- (void)disableField;

- (void)showLoading;
- (void)hideLoading;

@end
