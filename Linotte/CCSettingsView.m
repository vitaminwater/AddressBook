//
//  CCAddressSettingsView.m
//  Linotte
//
//  Created by stant on 25/08/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCSettingsView.h"

#import <HexColors/HexColor.h>

#import "NSString+CCLocalizedString.h"

@interface CCSettingsView()

@property(nonatomic, strong)UILabel *titleLabel;
@property(nonatomic, strong)UIButton *closeButton;

// settings items
@property(nonatomic, strong)UIView *notificationSettingsView;
@property(nonatomic, strong)UIButton *notificationToggleButton;

@property(nonatomic, strong)UIView *listSettingsView;
@property(nonatomic, strong)UILabel *currentListName;

@end

@implementation CCSettingsView

- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"#6b6b6b" alpha:0.85];
        self.alpha = 0.5;
        self.opaque = NO;
        self.layer.cornerRadius = 15;
        self.layer.masksToBounds = YES;
        
        [self setupTitle];
        [self setupNotificationSetting];
        [self setupListSetting];
        [self setupCloseButton];
        [self setupLayout];
    }
    return self;
}

- (void)setupTitle
{
    _titleLabel = [UILabel new];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:25];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.text = NSLocalizedString(@"SETTINGS", @"");
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleLabel];
}

- (void)setupNotificationSetting
{
    _notificationSettingsView = [UIView new];
    _notificationSettingsView.translatesAutoresizingMaskIntoConstraints = NO;
    _notificationSettingsView.backgroundColor = [UIColor clearColor];
    [self addSubview:_notificationSettingsView];
    
    UILabel *settingLabel = [UILabel new];
    settingLabel.translatesAutoresizingMaskIntoConstraints = NO;
    settingLabel.font = [UIFont fontWithName:@"Futura-Book" size:18];
    settingLabel.textColor = [UIColor whiteColor];
    settingLabel.text = NSLocalizedString(@"NOTIFICATION_SETTING", @"");
    [_notificationSettingsView addSubview:settingLabel];
    
    _notificationToggleButton = [UIButton new];
    _notificationToggleButton.translatesAutoresizingMaskIntoConstraints = NO;
    _notificationToggleButton.titleLabel.font = [UIFont fontWithName:@"Futura-Book" size:20];
    [_notificationToggleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_notificationToggleButton addTarget:self action:@selector(notificationTogglePressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [_notificationToggleButton setTitle:@"YES" forState:UIControlStateSelected];
    [_notificationToggleButton setTitleColor:[UIColor colorWithHexString:@"#5acfc4"] forState:UIControlStateSelected];
    
    [_notificationToggleButton setTitle:@"NO" forState:UIControlStateNormal];
    [_notificationToggleButton setTitleColor:[UIColor colorWithHexString:@"#f4607c"] forState:UIControlStateNormal];
    [_notificationSettingsView addSubview:_notificationToggleButton];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(settingLabel, _notificationToggleButton);
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[settingLabel][_notificationToggleButton]-|" options:0 metrics:nil views:views];
    [_notificationSettingsView addConstraints:horizontalConstraints];
    
    for (UIView *view in views.allValues) {
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view"  : view}];
        [_notificationSettingsView addConstraints:verticalConstraints];
    }
}

- (void)setupListSetting
{
    _listSettingsView = [UIView new];
    _listSettingsView.translatesAutoresizingMaskIntoConstraints = NO;
    _listSettingsView.backgroundColor = [UIColor clearColor];
    [self addSubview:_listSettingsView];
    
    _currentListName = [UILabel new];
    _currentListName.translatesAutoresizingMaskIntoConstraints = NO;
    _currentListName.font = [UIFont fontWithName:@"Futura-Book" size:18];
    _currentListName.textColor = [UIColor whiteColor];
    _currentListName.textAlignment = NSTextAlignmentCenter;
    _currentListName.numberOfLines = 0;
    [_listSettingsView addSubview:_currentListName];
    
    UIButton *changeListButton = [UIButton new];
    changeListButton.translatesAutoresizingMaskIntoConstraints = NO;
    [changeListButton setTitle:NSLocalizedString(@"CHANGE_LIST_BUTTON", @"") forState:UIControlStateNormal];
    [changeListButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [changeListButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [changeListButton addTarget:self action:@selector(changeListPressed:) forControlEvents:UIControlEventTouchUpInside];
    changeListButton.backgroundColor = [UIColor colorWithHexString:@"#5acfc4"];
    changeListButton.layer.cornerRadius = 5;
    [_listSettingsView addSubview:changeListButton];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_currentListName, changeListButton);
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_currentListName]-(==5)-[changeListButton]-|" options:0 metrics:nil views:views];
    [_listSettingsView addConstraints:horizontalConstraints];
    
    for (UIView *view in views.allValues) {
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[view]-|" options:0 metrics:nil views:@{@"view"  : view}];
        [_listSettingsView addConstraints:verticalConstraints];
    }
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
    NSDictionary *views = NSDictionaryOfVariableBindings(_titleLabel, _notificationSettingsView, _listSettingsView, _closeButton);
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_titleLabel(==50)]-[_notificationSettingsView]-[_listSettingsView]-[_closeButton(==35)]|" options:0 metrics:nil views:views];
    [self addConstraints:verticalConstraints];
    
    for (UIView *view in views.allValues) {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": view}];
        [self addConstraints:horizontalConstraints];
    }
}

#pragma mark - getter/setter methods

- (void)setNotificationEnabled:(BOOL)notificationEnabled
{
    _notificationToggleButton.selected = notificationEnabled;
}

- (void)setListNames:(NSString *)listNames
{
    _listNames = listNames;
    if (listNames.length)
        _currentListName.text = [NSString localizedStringByReplacingFromDictionnary:@{@"[ListNames]" : listNames} localizedKey:@"LIST_SETTING"];
    else
        _currentListName.text = NSLocalizedString(@"NO_LIST_SETTING", @"");
}

#pragma mark - UIButton target methods

- (void)closeButtonPressed:(UIButton *)sender
{
    [_delegate closeButtonPressed:self];
}

- (void)notificationTogglePressed:(UIButton *)sender
{
    sender.selected = !sender.selected;
    [_delegate setNotificationEnabled:sender.selected];
}

- (void)changeListPressed:(UIButton *)sender
{
    [_delegate showListSetting];
}

@end
