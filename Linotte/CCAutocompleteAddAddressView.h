//
//  CCAddAddressView.h
//  Linotte
//
//  Created by stant on 24/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCAutocompleteAddAddressViewDelegate.h"

@class CCAddAddressTabButtons;

@interface CCAutocompleteAddAddressView : UIView<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property(nonatomic, weak)id<CCAutocompleteAddAddressViewDelegate> delegate;

@property(nonatomic, strong)CCAddAddressTabButtons *tabButtons;
@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)UITextField *autocompletedField;
@property(nonatomic, strong)NSString *nameFieldValue;

- (void)setFirstInputAsFirstResponder;
- (void)cleanBeforeClose;

- (void)setupViews;
- (void)setupLayout;

- (void)reloadAutocompletionResults;

- (void)enableField;
- (void)disableField;

- (void)showLoading:(NSString *)message;
- (void)hideLoading;

- (void)resetTabButtonPosition;

@end
