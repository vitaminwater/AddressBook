//
//  CCAddListView.m
//  Linotte
//
//  Created by stant on 17/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCAddListView.h"

@interface CCAddListView()

@property(nonatomic, strong)UITextField *textField;

@end

@implementation CCAddListView

- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self setupTextField];
        [self setupLayout];
    }
    return self;
}

- (void)setupTextField
{
    _textField = [UITextField new];
    _textField.translatesAutoresizingMaskIntoConstraints = NO;
    _textField.font = [UIFont fontWithName:@"Montserrat-Bold" size:28];
    _textField.textColor = [UIColor darkGrayColor];
    _textField.backgroundColor = [UIColor whiteColor];
    _textField.placeholder = NSLocalizedString(@"LIST_NAME", @"");
    _textField.delegate = self;
    
    UIImageView *leftView = [UIImageView new];
    leftView.frame = CGRectMake(0, 0, 58, [kCCAddViewTextFieldHeight floatValue]);
    leftView.contentMode = UIViewContentModeCenter;
    leftView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    leftView.image = [UIImage imageNamed:@"add_book_icon"];
    _textField.leftView = leftView;
    _textField.leftViewMode = UITextFieldViewModeAlways;
    
    UIButton *cancelButton = [UIButton new];
    [cancelButton setImage:[UIImage imageNamed:@"cancel_button"] forState:UIControlStateNormal];
    cancelButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    cancelButton.frame = CGRectMake(0, 0, 40, [kCCAddViewTextFieldHeight floatValue]);
    cancelButton.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [cancelButton addTarget:self action:@selector(cancelPressed:) forControlEvents:UIControlEventTouchUpInside];
    _textField.rightView = cancelButton;
    _textField.rightViewMode = UITextFieldViewModeWhileEditing;
    
    [self addSubview:_textField];
}

- (void)setupLayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_textField);
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_textField(kCCAddViewTextFieldHeight)]|" options:0 metrics:kCCAddViewTextFieldHeightMetric views:views];
    [self addConstraints:verticalConstraints];
    
    for (UIView *view in views.allValues) {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
        [self addConstraints:horizontalConstraints];
    }
}

#pragma mark - UIButton target methods

- (void)cancelPressed:(UIButton *)sender
{
    [_textField resignFirstResponder];
    _textField.text = @"";
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [_delegate createListWithName:textField.text];
    return NO;
}

@end
