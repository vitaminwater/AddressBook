//
//  CCAddAddressByAddressView.m
//  Linotte
//
//  Created by stant on 25/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCAddAddressByAddressView.h"

#import "CCAlertView.h"
#import "CCLinotteField.h"

#define kCCAddAddressViewMetrics @{@"kCCAddTextFieldHeight" : kCCLinotteTextFieldHeight}

@implementation CCAddAddressByAddressView
{
    UITextField *_nameField;
}

@dynamic nameFieldValue;

- (void)setupViews
{
    [super setupViews];
    [self setupNameField];
    [self setupAddressField];
    
    self.tableView.rowHeight = 40;
}

- (void)setupNameField
{
    _nameField = [[CCLinotteField alloc] initWithImage:[UIImage imageNamed:@"add_field_icon"]];
    _nameField.translatesAutoresizingMaskIntoConstraints = NO;
    _nameField.placeholder = NSLocalizedString(@"PLACE_NAME", @"");
    _nameField.delegate = self;
    [self addSubview:_nameField];
}

- (void)setupAddressField
{
    self.autocompletedField.placeholder = NSLocalizedString(@"ENTER_ADDRESS", @"");
    
    UIImageView *leftView = (UIImageView *)self.autocompletedField.leftView;
    leftView.image = [UIImage imageNamed:@"small_gmap_pin_neutral"];
}

- (void)setupLayout
{
    [super setupLayout];
    UIView *autocompletedField = self.autocompletedField;
    UIView *tableView = self.tableView;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_nameField, autocompletedField, tableView);
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_nameField(==kCCAddTextFieldHeight)][autocompletedField(==kCCAddTextFieldHeight)][tableView]|" options:0 metrics:kCCAddAddressViewMetrics views:views];
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

- (void)cleanBeforeClose
{
    _nameField.text = @"";
    [_nameField resignFirstResponder];
    [super cleanBeforeClose];
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _nameField) {
        [self.autocompletedField becomeFirstResponder];
    } else {
        [super textFieldShouldReturn:textField];
    }
    return NO;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_nameField.text length] == 0) {
        [CCAlertView showAlertViewWithText:NSLocalizedString(@"ADDRESS_NAME_MISSING", @"") target:self leftAction:@selector(missingNameAlertViewLeftAction:) rightAction:@selector(missingNameAlertViewRightAction:)];
        return;
    }
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark - CCAlertView target methods

- (void)missingNameAlertViewLeftAction:(id)sender
{
    [CCAlertView closeAlertView:sender];
    [_nameField becomeFirstResponder];
}

- (void)missingNameAlertViewRightAction:(id)sender
{
    [CCAlertView closeAlertView:sender];
    [_nameField resignFirstResponder];
    [self.autocompletedField resignFirstResponder];
}

#pragma mark - getter methods

- (void)setNameFieldValue:(NSString *)nameFieldValue
{
    _nameField.text = nameFieldValue;
}

- (NSString *)nameFieldValue
{
    return _nameField.text;
}

@end
