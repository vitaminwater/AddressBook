//
//  CCAddAddressView.h
//  Linotte
//
//  Created by stant on 24/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCAutocompleteAddAddressViewDelegate.h"

@interface CCAutocompleteAddAddressView : UIView<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property(nonatomic, weak)id<CCAutocompleteAddAddressViewDelegate> delegate;

@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)UITextField *autocompletedField;

- (void)setFirstInputAsFirstResponder;

- (void)setupViews;
- (void)setupLayout;

- (void)reloadAutocompletionResults;

- (void)enableField;
- (void)disableField;

- (void)showLoading:(NSString *)message;
- (void)hideLoading;

@end
