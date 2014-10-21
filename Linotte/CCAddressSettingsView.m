//
//  CCAddressSettingsView.m
//  Linotte
//
//  Created by stant on 25/08/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCAddressSettingsView.h"

#import <HexColors/HexColor.h>

#import "NSString+CCLocalizedString.h"


@implementation CCAddressSettingsView
{
    UIView *_notificationSettingsView;
    UIButton *_notificationToggleButton;
    
    UIView *_listSettingsView;
    UILabel *_currentListName;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self setupNotificationSetting];
        [self setupListSetting];
        [self setupLayout];
    }
    return self;
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

- (void)setupLayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_notificationSettingsView, _listSettingsView);
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_notificationSettingsView]-[_listSettingsView]|" options:0 metrics:nil views:views];
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
