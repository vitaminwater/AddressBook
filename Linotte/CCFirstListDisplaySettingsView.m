//
//  CCFirstDisplayListSettingsView.m
//  Linotte
//
//  Created by stant on 19/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCFirstListDisplaySettingsView.h"

#import <HexColors/HexColor.h>

@implementation CCFirstListDisplaySettingsView
{
    UITextView *_textView;
    UIButton *_enableNotificationButton;
    UIButton *_disableNotificationButton;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self setupTextView];
        [self setupNotificationButtons];
        [self setupLayout];
    }
    return self;
}

- (void)setupTextView
{
    _textView = [UITextView new];
    _textView.translatesAutoresizingMaskIntoConstraints = NO;
    _textView.backgroundColor = [UIColor clearColor];
    _textView.textAlignment = NSTextAlignmentCenter;
    _textView.scrollEnabled = NO;
    _textView.editable = NO;
    
    NSString *addressCreated = NSLocalizedString(@"ADDRESSCREATED", @"");
    NSString *addressCreatedSubText = NSLocalizedString(@"ADDRESSCREATED_SUBTEXT", @"");
    NSString *text = [NSString stringWithFormat:@"%@\n\n%@", addressCreated, addressCreatedSubText];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedString setAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Futura-Book" size:25], NSForegroundColorAttributeName : [UIColor whiteColor], NSParagraphStyleAttributeName : paragraphStyle} range:(NSRange){.location=0, .length=[addressCreated length]}];
    [attributedString setAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Futura-Book" size:20], NSForegroundColorAttributeName : [UIColor whiteColor], NSParagraphStyleAttributeName : paragraphStyle} range:(NSRange){.location=[addressCreated length] + 2, .length=[addressCreatedSubText length]}];
    _textView.attributedText = attributedString;
    
    [self addSubview:_textView];
}

- (void)setupNotificationButtons
{
    _enableNotificationButton = [self createButton];
    _enableNotificationButton.backgroundColor = [UIColor colorWithHexString:@"#5acfc4"];
    [_enableNotificationButton setTitle:NSLocalizedString(@"ENABLE_NOTIF_BUTTON_TEXT", @"") forState:UIControlStateNormal];
    [_enableNotificationButton addTarget:self action:@selector(enableNotificationButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _enableNotificationButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _enableNotificationButton.layer.borderWidth = 0;
    
    _disableNotificationButton = [self createButton];
    _disableNotificationButton.backgroundColor = [UIColor colorWithHexString:@"#f4607c"];
    [_disableNotificationButton setTitle:NSLocalizedString(@"DISABLE_NOTIF_BUTTON_TEXT", @"") forState:UIControlStateNormal];
    [_disableNotificationButton addTarget:self action:@selector(disableNotificationButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _disableNotificationButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _disableNotificationButton.layer.borderWidth = 4;
}

- (UIButton *)createButton
{
    UIButton *button = [UIButton new];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.layer.cornerRadius = 10;
    button.layer.masksToBounds = YES;
    button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:button];
    return button;
}

- (void)setupLayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_textView, _enableNotificationButton, _disableNotificationButton);
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_textView]-|" options:0 metrics:nil views:views];
    [self addConstraints:horizontalConstraints];
    
    NSArray *horizontalButtonConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_enableNotificationButton(>=120)]-[_disableNotificationButton(==_enableNotificationButton)]-|" options:0 metrics:nil views:views];
    [self addConstraints:horizontalButtonConstraints];
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_textView]-[_enableNotificationButton]-|" options:0 metrics:nil views:views];
    [self addConstraints:verticalConstraints];
    
    NSLayoutConstraint *centerYRightButtonConstraint = [NSLayoutConstraint constraintWithItem:_enableNotificationButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_disableNotificationButton attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    [self addConstraint:centerYRightButtonConstraint];
    
    NSLayoutConstraint *centerHeightRightButtonConstraint = [NSLayoutConstraint constraintWithItem:_enableNotificationButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_disableNotificationButton attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    [self addConstraint:centerHeightRightButtonConstraint];
}

#pragma mark - UIButton target methods

- (void)enableNotificationButtonPressed:(id)sender
{
    [_delegate setNotificationEnabled:YES];
    _enableNotificationButton.layer.borderWidth = 4;
    _disableNotificationButton.layer.borderWidth = 0;
}

- (void)disableNotificationButtonPressed:(id)sender
{
    [_delegate setNotificationEnabled:NO];
    _enableNotificationButton.layer.borderWidth = 0;
    _disableNotificationButton.layer.borderWidth = 4;
}

@end
