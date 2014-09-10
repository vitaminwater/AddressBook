//
//  CCOutputConfirmEntryView.m
//  Linotte
//
//  Created by stant on 11/08/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCOutputConfirmEntryView.h"

#import <HexColors/HexColor.h>

@interface CCOutputConfirmEntryView()

@property(nonatomic, strong)UITextView *textView;
@property(nonatomic, strong)UIButton *enableNotificationButton;
@property(nonatomic, strong)UIButton *disableNotificationButton;
@property(nonatomic, strong)UIButton *listButton;

@property(nonatomic, strong)UIButton *closeButton;

@end

@implementation CCOutputConfirmEntryView

- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"#6b6b6b" alpha:0.85];
        self.alpha = 0.5;
        self.opaque = NO;
        self.layer.cornerRadius = 15;
        self.layer.masksToBounds = YES;
        
        _notificationEnabled = YES;
        
        [self setupTextView];
        [self setupNotificationButtons];
        [self setupListButton];
        [self setupCloseButton];
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
    _enableNotificationButton.layer.borderWidth = 4;
    
    _disableNotificationButton = [self createButton];
    _disableNotificationButton.backgroundColor = [UIColor colorWithHexString:@"#f4607c"];
    [_disableNotificationButton setTitle:NSLocalizedString(@"DISABLE_NOTIF_BUTTON_TEXT", @"") forState:UIControlStateNormal];
    [_disableNotificationButton addTarget:self action:@selector(disableNotificationButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _disableNotificationButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _disableNotificationButton.layer.borderWidth = 0;
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

- (void)setupListButton
{
    _listButton = [UIButton new];
    _listButton.translatesAutoresizingMaskIntoConstraints = NO;
    _listButton.backgroundColor = [UIColor colorWithHexString:@"#ffae64"];
    _listButton.layer.cornerRadius = 5;
    [_listButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_listButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_listButton addTarget:self action:@selector(listButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_listButton setTitle:NSLocalizedString(@"SHOW_LIST_SETTING", @"") forState:UIControlStateNormal];
    [self addSubview:_listButton];
}

- (void)setupCloseButton
{
    _closeButton = [UIButton new];
    _closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_closeButton setTitle:NSLocalizedString(@"CLOSE", @"") forState:UIControlStateNormal];
    [_closeButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    _closeButton.titleLabel.font = [UIFont fontWithName:@"Futura-Book" size:19];
    [_closeButton setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.5]];
    [_closeButton addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _closeButton.opaque = NO;
    [self addSubview:_closeButton];
}

- (void)setupLayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_textView, _enableNotificationButton, _disableNotificationButton, _listButton, _closeButton);
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_textView]-|" options:0 metrics:nil views:views];
    [self addConstraints:horizontalConstraints];
    
    NSArray *horizontalButtonConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_enableNotificationButton(>=120)]-[_disableNotificationButton(==_enableNotificationButton)]-|" options:0 metrics:nil views:views];
    [self addConstraints:horizontalButtonConstraints];
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_textView]-[_enableNotificationButton]-[_listButton]-[_closeButton]|" options:0 metrics:nil views:views];
    [self addConstraints:verticalConstraints];
    
    NSLayoutConstraint *centerYRightButtonConstraint = [NSLayoutConstraint constraintWithItem:_enableNotificationButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_disableNotificationButton attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    [self addConstraint:centerYRightButtonConstraint];
    
    NSLayoutConstraint *centerHeightRightButtonConstraint = [NSLayoutConstraint constraintWithItem:_enableNotificationButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_disableNotificationButton attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    [self addConstraint:centerHeightRightButtonConstraint];
    
    NSArray *listButtonWidthConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-[_listButton]-|" options:0 metrics:nil views:views];
    [self addConstraints:listButtonWidthConstraints];
    
    NSArray *closeButtonWidthConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[_closeButton]|" options:0 metrics:nil views:views];
    [self addConstraints:closeButtonWidthConstraints];
}

#pragma mark - UIButton target methods

- (void)listButtonPressed:(UIButton *)sender
{
    [_delegate showListSetting];
}

- (void)closeButtonPressed:(UIButton *)sender
{
    [_delegate closeConfirmView:self];
}

- (void)enableNotificationButtonPressed:(id)sender
{
    _notificationEnabled = YES;
    _enableNotificationButton.layer.borderWidth = 4;
    _disableNotificationButton.layer.borderWidth = 0;
}

- (void)disableNotificationButtonPressed:(id)sender
{
    _notificationEnabled = NO;
    _enableNotificationButton.layer.borderWidth = 0;
    _disableNotificationButton.layer.borderWidth = 4;
}

@end
