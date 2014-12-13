//
//  CCEmailLoginView.m
//  Linotte
//
//  Created by stant on 08/12/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCEmailLoginView.h"

#import <HexColors/HexColor.h>

#import "CCFlatColorButton.h"
#import "CCActionResultHUD.h"
#import "CCEmailLoginField.h"

#define kCCLoginFieldsHeight @40

@implementation CCEmailLoginView
{
    UITextField *_emailField;
    UITextField *_passwordField;
    
    UIView *_buttonView;
    CCFlatColorButton *_okButton;
    
    NSMutableArray *_fields;
    NSMutableArray *_buttons;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.opaque = YES;
        _fields = [@[] mutableCopy];
        _buttons = [@[] mutableCopy];
        
        [self setupEmailField];
        [self setupPasswordField];
        [self setupButtonView];
        [self setupLayout];
    }
    return self;
}

#pragma mark - setup methods

#pragma mark Fields setup methods

- (void)setupEmailField
{
    _emailField = [self createTextField];
    _emailField.placeholder = NSLocalizedString(@"EMAIL_PLACEHOLDER", @"");
    _emailField.keyboardType = UIKeyboardTypeEmailAddress;
    _emailField.returnKeyType = UIReturnKeyNext;
}

- (void)setupPasswordField
{
    _passwordField = [self createPaswordField];
    _passwordField.placeholder = NSLocalizedString(@"PASSWORD_PLACEHOLDER", @"");
    _passwordField.returnKeyType = UIReturnKeyJoin;
}

- (UITextField *)createTextField
{
    UITextField *textField = [CCEmailLoginField new];
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    textField.delegate = self;
    textField.font = [UIFont fontWithName:@"Futura-Book" size:18];
    textField.textColor = [UIColor grayColor];
    textField.backgroundColor = [UIColor clearColor];
    [self addSubview:textField];
    
    [_fields addObject:textField];
    
    return textField;
}

- (UITextField *)createPaswordField
{
    UITextField *textField = [self createTextField];
    textField.secureTextEntry = YES;
    return textField;
}

#pragma mark Button setup methods

- (void)setupButtonView
{
    _buttonView = [UIButton new];
    _buttonView.translatesAutoresizingMaskIntoConstraints = NO;
    _buttonView.backgroundColor = [UIColor clearColor];
    [self addSubview:_buttonView];
    
    [self setupOkButton];
    
    {
        NSDictionary *views = NSDictionaryOfVariableBindings( _okButton);
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_okButton]|" options:0 metrics:nil views:views];
        [_buttonView addConstraints:horizontalConstraints];
        
        for (UIView *view in views.allValues) {
            NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
            [_buttonView addConstraints:verticalConstraints];
        }
    }
}

- (void)setupOkButton
{
    _okButton = [self createButton];
    [_okButton setTitle:NSLocalizedString(@"OK", @"") forState:UIControlStateNormal];
    _okButton.backgroundColor = [UIColor colorWithHexString:@"#5acfc4"];
    [_okButton setBackgroundColor:[UIColor colorWithHexString:@"#4abfb4"] forState:UIControlStateHighlighted];
    [_okButton addTarget:self action:@selector(okButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (CCFlatColorButton *)createButton
{
    CCFlatColorButton *button = [CCFlatColorButton new];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.layer.cornerRadius = 4;
    button.clipsToBounds = YES;
    [_buttonView addSubview:button];
    
    [_buttons addObject:button];
    
    return button;
}

#pragma mark -

- (void)setupLayout
{
    NSDictionary *metrics = @{@"kCCLoginFieldsHeight" : kCCLoginFieldsHeight};
    NSDictionary *views = NSDictionaryOfVariableBindings(_emailField, _passwordField, _buttonView);
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_emailField(==kCCLoginFieldsHeight)]-[_passwordField(==kCCLoginFieldsHeight)]-[_buttonView]|" options:0 metrics:metrics views:views];
    [self addConstraints:verticalConstraints];
    
    for (UIView *view in views.allValues) {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
        [self addConstraints:horizontalConstraints];
    }
}

#pragma mark - validate and submit form

- (void)validateAndSubmitForm
{
    [_emailField resignFirstResponder];
    [_passwordField resignFirstResponder];
    if ([self validateEmail] == NO) {
        _emailField.layer.borderColor = [UIColor redColor].CGColor;
        _emailField.layer.borderWidth = 1;
        [CCActionResultHUD showActionResultWithImage:[UIImage imageNamed:@"sad_icon"] text:NSLocalizedString(@"ENTER_VALID_EMAIL", @"") delay:3];
        return;
    }
    if ([self validatePasswords] == NO) {
        _passwordField.layer.borderColor = [UIColor redColor].CGColor;
        _passwordField.layer.borderWidth = 1;
        [CCActionResultHUD showActionResultWithImage:[UIImage imageNamed:@"sad_icon"] text:NSLocalizedString(@"ENTER_VALID_PASSWORDS", @"") delay:3];
        _passwordField.text = @"";
        return;
    }
    [_delegate loginSignupButtonPressed:_emailField.text password:_passwordField.text];
}

#pragma mark - validation methods

- (BOOL)validateEmail
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:_emailField.text];
}

- (BOOL)validatePasswords
{
    return [_passwordField.text length] != 0;
}

#pragma mark - UIButton target methods

- (void)okButtonPressed:(UIButton *)sender
{
    [self validateAndSubmitForm];
}

#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.layer.borderColor = [UIColor clearColor].CGColor;
    textField.layer.borderWidth = 0;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _emailField) {
        [_passwordField becomeFirstResponder];
    } else if (textField == _passwordField) {
        [self validateAndSubmitForm];
    }
    return NO;
}

@end
