//
//  CCListOutputView.m
//  Linotte
//
//  Created by stant on 10/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListOutputView.h"

#define kCCListHeaderViewHeight @150


@implementation CCListOutputView
{
    UIView *_listHeaderView;
    UIImageView *_listIcon;
    UITextView *_listInfos;
    
    UIView *_listNotificationView;
    UIButton *_listNotificationButton;
    
    UIView *_addView;
    UIView *_listView;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self setupListHeader];
        [self setupListNotificationView];
    }
    return self;
}

- (void)setupListHeader
{
    _listHeaderView = [UIView new];
    _listHeaderView.translatesAutoresizingMaskIntoConstraints = NO;
    [_listHeaderView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self addSubview:_listHeaderView];
    
    _listIcon = [UIImageView new];
    _listIcon.translatesAutoresizingMaskIntoConstraints = NO;
    [_listIcon setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    _listIcon.contentMode = UIViewContentModeScaleAspectFit;
    [_listHeaderView addSubview:_listIcon];
    
    _listInfos = [UITextView new];
    _listInfos.translatesAutoresizingMaskIntoConstraints = NO;
    _listInfos.font = [UIFont fontWithName:@"Futura-Book" size:21];
    _listInfos.textAlignment = NSTextAlignmentCenter;
    _listInfos.scrollEnabled = NO;
    _listInfos.editable = NO;
    _listInfos.backgroundColor = [UIColor clearColor];
    _listInfos.textColor = [UIColor darkGrayColor];
    [_listInfos setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [_listHeaderView addSubview:_listInfos];
    
    {
        NSDictionary *views = NSDictionaryOfVariableBindings(_listIcon, _listInfos);
        
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==8)-[_listIcon(==100)][_listInfos]-(==8)-|" options:0 metrics:nil views:views];
        [_listHeaderView addConstraints:verticalConstraints];
        
        for (UIView *view in views.allValues) {
            NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
            [_listHeaderView addConstraints:horizontalConstraints];
        }
    }
}

- (void)setupListNotificationView
{
    _listNotificationView = [UIView new];
    _listNotificationView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_listNotificationView];
    
    UILabel *listNotificationLabel = [UILabel new];
    listNotificationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    listNotificationLabel.textAlignment = NSTextAlignmentCenter;
    listNotificationLabel.text = NSLocalizedString(@"LIST_NOTIFICATION_LABEL", @"");
    listNotificationLabel.font = [UIFont fontWithName:@"Futura-Book" size:17];
    listNotificationLabel.numberOfLines = 0;
    listNotificationLabel.backgroundColor = [UIColor clearColor];
    listNotificationLabel.textColor = [UIColor darkGrayColor];
    [_listNotificationView addSubview:listNotificationLabel];
    
    _listNotificationButton = [UIButton new];
    _listNotificationButton.translatesAutoresizingMaskIntoConstraints = NO;
    _listNotificationButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_listNotificationButton setImage:[UIImage imageNamed:@"notification_button_off"] forState:UIControlStateNormal];
    [_listNotificationButton setImage:[UIImage imageNamed:@"notification_button_on"] forState:UIControlStateSelected];
    [_listNotificationButton addTarget:self action:@selector(notificationPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_listNotificationView addSubview:_listNotificationButton];
    
    {
        NSDictionary *views = NSDictionaryOfVariableBindings(listNotificationLabel, _listNotificationButton);
        
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(==8)-[listNotificationLabel][_listNotificationButton]-(==8)-|" options:0 metrics:nil views:views];
        [_listNotificationView addConstraints:horizontalConstraints];
        
        for (UIView *view in views.allValues) {
            NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==10)-[view]-(==10)-|" options:0 metrics:nil views:@{@"view" : view}];
            [_listNotificationView addConstraints:verticalConstraints];
        }
    }
}

- (void)setupAddView:(UIView *)addView
{
    _addView = addView;
    
    _addView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_addView];
}

- (void)setupListView:(UIView *)listView
{
    _listView = listView;
    
    _listView.translatesAutoresizingMaskIntoConstraints = NO;
    [self insertSubview:_listView belowSubview:_addView];
}

- (void)setupLayout
{
    [self removeConstraints:self.constraints];

    // list header
    {
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:_listHeaderView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        [self addConstraint:topConstraint];
    }
    
    // list notification view
    {
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:_listNotificationView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_listHeaderView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        [self addConstraint:topConstraint];
    }
    
    // add view
    {
        if (_addViewExpanded) {
            NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:_addView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
            [self addConstraint:topConstraint];
            
            NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:_addView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:-[kCCAddViewKeyboardHeight doubleValue]];
            [self addConstraint:bottomConstraint];
        } else {
            NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:_addView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_listNotificationView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
            [self addConstraint:topConstraint];
            
            NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:_addView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:[kCCAddViewTextFieldHeight doubleValue]];
            [self addConstraint:heightConstraint];
        }
    }
    
    // list view
    {
        if (_addViewExpanded) {
            NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:_listView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_listNotificationView attribute:NSLayoutAttributeBottom multiplier:1 constant:[kCCAddViewTextFieldHeight doubleValue]];
            [self addConstraint:topConstraint];
        } else {
            NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:_listView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_addView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
            [self addConstraint:topConstraint];
        }
        
        NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:_listView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        [self addConstraint:bottomConstraint];
    }
    
    // horizontal constraints
    {
        NSDictionary *views = NSDictionaryOfVariableBindings(_listHeaderView, _listNotificationView, _addView, _listView);
        
        for (UIView *view in views.allValues) {
            NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
            [self addConstraints:horizontalConstraints];
        }
    }
}

- (void)setListIconImage:(UIImage *)image
{
    _listIcon.image = image;
}

- (void)setListInfosText:(NSString *)listInfos
{
    _listInfos.text = listInfos;
}

- (void)setNotificationEnabled:(BOOL)notificationEnabled
{
    _listNotificationButton.selected = notificationEnabled;
}

#pragma mark - UIButton target methods

- (void)notificationPressed:(id)sender
{
    _listNotificationButton.selected = !_listNotificationButton.selected;
    [_delegate notificationEnabled:_listNotificationButton.selected];
}

@end
