//
//  CCListOutputView.m
//  Linotte
//
//  Created by stant on 10/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListOutputView.h"

#import <AFNetworking/UIImageView+AFNetworking.h>

#import "CCAnimationDelegator.h"

#import "CCListView.h"

#define kCCListOutputViewHeaderConstraintTimelineTween @"kCCListOutputViewHeaderConstraintTimelineTween"
#define kCCListHeaderViewHeight @150


@implementation CCListOutputView
{
    UIView *_listHeaderView;
    UIImageView *_listIcon;
    UITextView *_listInfos;
    
    UIView *_listNotificationView;
    UIButton *_listNotificationButton;
    
    CCListView *_listView;
    
    NSMutableArray *_constraints;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.opaque = YES;
        
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
        
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==8)-[_listIcon(==150)][_listInfos]-(==8)-|" options:0 metrics:nil views:views];
        [_listHeaderView addConstraints:verticalConstraints];
        
        for (UIView *view in views.allValues) {
            NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[view]-|" options:0 metrics:nil views:@{@"view" : view}];
            [_listHeaderView addConstraints:horizontalConstraints];
        }
    }
}

- (void)setupListNotificationView
{
    _listNotificationView = [UIView new];
    _listNotificationView.translatesAutoresizingMaskIntoConstraints = NO;
    _listNotificationView.backgroundColor = [UIColor whiteColor];
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
    
    UIView *separatorView = [UIView new];
    separatorView.translatesAutoresizingMaskIntoConstraints = NO;
    separatorView.backgroundColor = [UIColor grayColor];
    [_listNotificationView addSubview:separatorView];
    
    {
        NSDictionary *views = NSDictionaryOfVariableBindings(listNotificationLabel, _listNotificationButton);
        
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(==8)-[listNotificationLabel][_listNotificationButton]-(==8)-|" options:0 metrics:nil views:views];
        [_listNotificationView addConstraints:horizontalConstraints];
        
        for (UIView *view in views.allValues) {
            NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==10)-[view]-(==10)-|" options:0 metrics:nil views:@{@"view" : view}];
            [_listNotificationView addConstraints:verticalConstraints];
        }
    }
    
    // separator view
    {
        NSDictionary *views = NSDictionaryOfVariableBindings(separatorView);
        
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[separatorView]|" options:0 metrics:nil views:views];
        [_listNotificationView addConstraints:horizontalConstraints];
        
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[separatorView(==1)]|" options:0 metrics:nil views:views];
        [_listNotificationView addConstraints:verticalConstraints];
    }
}

- (void)setupListView:(CCListView *)listView
{
    _listView = listView;
    
    _listView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_listView];
}

- (void)setupLayout
{
    if (_constraints)
        [self removeConstraints:_constraints];
    _constraints = [@[] mutableCopy];
    
    // list header
    {
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:_listHeaderView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        [_constraints addObject:topConstraint];
    }
    
    // list notification view
    {
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:_listNotificationView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_listHeaderView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        [_constraints addObject:topConstraint];
        
        __weak typeof(_listHeaderView) weakListHeaderView = _listHeaderView;
        __weak typeof(self) weakSelf = self;
        [_listView.animatorDelegator setTimeLineAnimationItemForKey:kCCListOutputViewHeaderConstraintTimelineTween animationBlock:^BOOL(CGFloat value) {
            if (value > 0) {
                if (topConstraint.constant >= 0)
                    return NO;
                topConstraint.constant = MIN(0, topConstraint.constant + value);
                [weakSelf layoutIfNeeded];
                return YES;
            } else {
                if (topConstraint.constant <= -weakListHeaderView.bounds.size.height)
                    return NO;
                topConstraint.constant = MAX(-weakListHeaderView.bounds.size.height, topConstraint.constant + value);
                [weakSelf layoutIfNeeded];
                return YES;
            }
            return NO;
        } fingerLiftBlock:^(){
            if (topConstraint.constant <= -weakListHeaderView.bounds.size.height / 2)
                topConstraint.constant = -weakListHeaderView.bounds.size.height;
            else
                topConstraint.constant = 0;
            [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:1 options:0 animations:^{
                [weakSelf layoutIfNeeded];
            } completion:^(BOOL finished){
            }];
        }];
    }
    
    // list view
    {
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:_listView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_listNotificationView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        [_constraints addObject:topConstraint];
        
        NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:_listView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        [_constraints addObject:bottomConstraint];
    }
    
    // horizontal constraints
    {
        NSDictionary *views = NSDictionaryOfVariableBindings(_listHeaderView, _listNotificationView, _listView);
        
        for (UIView *view in views.allValues) {
            NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
            [_constraints addObjectsFromArray:horizontalConstraints];
        }
    }
    
    [self addConstraints:_constraints];
}

- (void)loadListIconWithUrl:(NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@_in_app_big", kCCLinotteStaticServer, urlString]];
    [_listIcon setImageWithURL:url placeholderImage:[UIImage imageNamed:@"list_pin_neutral"]];
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
