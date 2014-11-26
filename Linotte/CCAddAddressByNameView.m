//
//  CCAddView.m
//  Linotte
//
//  Created by stant on 06/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCAddAddressByNameView.h"

#import "CCAddAddressViewTableViewCell.h"


@implementation CCAddAddressByNameView

- (void)setupLayout
{
    [super setupLayout];
    UIView *autocompletedField = self.autocompletedField;
    UIView *tableView = self.tableView;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(autocompletedField, tableView);
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[autocompletedField(kCCAddViewTextFieldHeight)][tableView]|" options:0 metrics:kCCAddViewTextFieldHeightMetric views:views];
    [self addConstraints:verticalConstraints];
    
    for (UIView *view in views.allValues) {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
        [self addConstraints:horizontalConstraints];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [super textFieldDidBeginEditing:textField];
    textField.placeholder = NSLocalizedString(@"ENTER_NAME", @"");
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.placeholder = NSLocalizedString(@"PLACE_NAME", @"");
}

@end
