//
//  CCAddView.m
//  Linotte
//
//  Created by stant on 06/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCAddAddressByNameView.h"

#import "CCAddAddressViewTableViewCell.h"

#define kCCAddAddressViewMetrics @{@"kCCAddTextFieldHeight" : kCCLinotteTextFieldHeight}

@implementation CCAddAddressByNameView

@dynamic nameFieldValue;

- (void)setupViews
{
    [super setupViews];
    self.autocompletedField.placeholder = NSLocalizedString(@"PLACE_NAME", @"");
}

- (void)setupLayout
{
    [super setupLayout];
    UIView *autocompletedField = self.autocompletedField;
    UIView *tableView = self.tableView;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(autocompletedField, tableView);
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[autocompletedField(kCCAddTextFieldHeight)][tableView]|" options:0 metrics:kCCAddAddressViewMetrics views:views];
    [self addConstraints:verticalConstraints];
    
    for (UIView *view in views.allValues) {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
        [self addConstraints:horizontalConstraints];
    }
}

#pragma mark - getter methods

- (void)setNameFieldValue:(NSString *)nameFieldValue
{
    self.autocompletedField.text = nameFieldValue;
}

- (NSString *)nameFieldValue
{
    return self.autocompletedField.text;
}

@end
