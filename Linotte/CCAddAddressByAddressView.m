//
//  CCAddAddressByAddressView.m
//  Linotte
//
//  Created by stant on 25/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCAddAddressByAddressView.h"

@implementation CCAddAddressByAddressView
{
    UITextField *_nameField;
}

@dynamic addressName;

- (void)setupViews
{
    [super setupViews];
    [self setupNameField];
    [self setupAddressField];
}

- (void)setupNameField
{
    _nameField = [UITextField new];
    _nameField.translatesAutoresizingMaskIntoConstraints = NO;
    _nameField.font = [UIFont fontWithName:@"Montserrat-Bold" size:28];
    _nameField.textColor = [UIColor darkGrayColor];
    _nameField.backgroundColor = [UIColor whiteColor];
    _nameField.placeholder = NSLocalizedString(@"PLACE_NAME", @"");
    _nameField.delegate = self;
    
    UIImageView *leftView = [UIImageView new];
    leftView.frame = CGRectMake(0, 0, 58, [kCCAddViewTextFieldHeight floatValue]);
    leftView.contentMode = UIViewContentModeCenter;
    leftView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    leftView.image = [UIImage imageNamed:@"add_field_icon"];
    _nameField.leftView = leftView;
    _nameField.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *rightView = [UIView new];
    rightView.frame = CGRectMake(0, 0, 15, [kCCAddViewTextFieldHeight floatValue]);
    rightView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _nameField.rightView = rightView;
    _nameField.rightViewMode = UITextFieldViewModeAlways;
    
    [_nameField addTarget:self action:@selector(nameFieldEventEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    
    [self addSubview:_nameField];
}

- (void)setupAddressField
{
    self.autocompletedField.placeholder = NSLocalizedString(@"ENTER_ADDRESS", @"");
}

- (void)setupLayout
{
    [super setupLayout];
    UIView *autocompletedField = self.autocompletedField;
    UIView *tableView = self.tableView;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_nameField, autocompletedField, tableView);
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_nameField(==kCCAddViewTextFieldHeight)]-(<=0)-[autocompletedField(==kCCAddViewTextFieldHeight)][tableView]|" options:0 metrics:kCCAddViewTextFieldHeightMetric views:views];
    [self addConstraints:verticalConstraints];
    
    for (UIView *view in views.allValues) {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
        [self addConstraints:horizontalConstraints];
    }
}

- (void)setFirstInputAsFirstResponder
{
    [_nameField becomeFirstResponder];
}

#pragma mark UITextField target methods

- (void)nameFieldEventEditingChanged:(UITextField *)textField
{
    self.autocompletedField.enabled = ![textField.text isEqualToString:@""];
}

#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _nameField)
        textField.placeholder = NSLocalizedString(@"PLACE_NAME", @"");
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == _nameField) {
        [self.delegate expandAddView];
        textField.placeholder = NSLocalizedString(@"ENTER_NAME", @"");
    } else
        [super textFieldDidBeginEditing:textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _nameField) {
        [self.autocompletedField becomeFirstResponder];
    } else {
        [super textFieldShouldReturn:textField];
    }
    return NO;
}

#pragma mark - getter methods

- (NSString *)addressName
{
    return _nameField.text;
}

@end
