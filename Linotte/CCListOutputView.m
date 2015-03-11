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
#import "CCLinotteField.h"

#define kCCListOutputViewHeaderConstraintTimelineTween @"kCCListOutputViewHeaderConstraintTimelineTween"
#define kCCListHeaderViewHeight @150
#define kCCListOutputSearchFieldHeight [kCCLinotteTextFieldHeight floatValue]


@implementation CCListOutputView
{
    UITextField *_searchField;
    NSString *_lastFilterText;
    UIView *_searchViewControllerView;
    NSLayoutConstraint *_searchViewControllerViewBottomConstraint;
    
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
        
        [self setupSearchField];
        [self setupListHeader];
        [self setupListNotificationView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupSearchField
{
    _searchField = [[CCLinotteField alloc] initWithImage:[UIImage imageNamed:@"search_icon"]];
    _searchField.translatesAutoresizingMaskIntoConstraints = NO;
    _searchField.placeholder = NSLocalizedString(@"SEARCH", @"");
    [_searchField addTarget:self action:@selector(searchFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    _searchField.delegate = self;
    [self addSubview:_searchField];
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
    
    // list header + search
    {
        NSDictionary *views = NSDictionaryOfVariableBindings(_searchField, _listHeaderView);
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_searchField][_listHeaderView]" options:0 metrics:nil views:views];
        [_constraints addObjectsFromArray:verticalConstraints];
    }
    
    NSLayoutConstraint *searchHeightConstraint = [NSLayoutConstraint constraintWithItem:_searchField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:0];
    [_constraints addObject:searchHeightConstraint];
    
    // list notification view
    {
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:_listNotificationView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_listHeaderView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        [_constraints addObject:topConstraint];
        
        __weak typeof(_searchField) weakSearchField = _searchField;
        __weak typeof(_listHeaderView) weakListHeaderView = _listHeaderView;
        __weak typeof(self) weakSelf = self;
        [_listView.animatorDelegator setTimeLineAnimationItemForKey:kCCListOutputViewHeaderConstraintTimelineTween animationBlock:^BOOL(CGFloat value) {
            if (value > 0) {
                if (topConstraint.constant < 0) {
                    topConstraint.constant = MIN(0, topConstraint.constant + value);
                    [weakSelf layoutIfNeeded];
                    return YES;
                } else if (topConstraint.constant >= 0 && searchHeightConstraint.constant < kCCListOutputSearchFieldHeight) {
                    searchHeightConstraint.constant = MIN(kCCListOutputSearchFieldHeight, searchHeightConstraint.constant + value);
                    [weakSelf layoutIfNeeded];
                    return YES;
                }
                return NO;
            } else {
                if (topConstraint.constant > -weakListHeaderView.bounds.size.height) {
                    topConstraint.constant = MAX(-weakListHeaderView.bounds.size.height, topConstraint.constant + value);
                    [weakSelf layoutIfNeeded];
                    return YES;
                } else if (topConstraint.constant <= -weakListHeaderView.bounds.size.height && searchHeightConstraint.constant > 0) {
                    [weakSearchField resignFirstResponder];
                    searchHeightConstraint.constant = MAX(0, searchHeightConstraint.constant + value);
                    [weakSelf layoutIfNeeded];
                    return YES;
                }
                return NO;
            }
            return NO;
        } fingerLiftBlock:^(){
            if (searchHeightConstraint.constant >= kCCListOutputSearchFieldHeight / 2) {
                //[weakSearchField becomeFirstResponder];
                searchHeightConstraint.constant = kCCListOutputSearchFieldHeight;
            } else {
                //[weakSearchField resignFirstResponder];
                searchHeightConstraint.constant = 0;
            }
            
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
        NSDictionary *views = NSDictionaryOfVariableBindings(_listNotificationView, _listView);
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_listNotificationView][_listView]|" options:0 metrics:nil views:views];
        [_constraints addObjectsFromArray:verticalConstraints];
    }
    
    // horizontal constraints
    {
        NSDictionary *views = NSDictionaryOfVariableBindings(_searchField, _listHeaderView, _listNotificationView, _listView);
        
        for (UIView *view in views.allValues) {
            NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
            [_constraints addObjectsFromArray:horizontalConstraints];
        }
    }
    
    [self addConstraints:_constraints];
}

- (void)searchFieldResignFirstResponder
{
    [_searchField resignFirstResponder];
}

- (void)presentSearchViewControllerView:(UIView *)searchViewControllerView
{
    _searchViewControllerView = searchViewControllerView;
    _searchViewControllerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_searchViewControllerView];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_searchField, _searchViewControllerView);
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_searchField][_searchViewControllerView]" options:0 metrics:nil views:views];
    [self addConstraints:verticalConstraints];
    
    _searchViewControllerViewBottomConstraint = [NSLayoutConstraint constraintWithItem:_searchViewControllerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [self addConstraint:_searchViewControllerViewBottomConstraint];
    
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_searchViewControllerView]|" options:0 metrics:nil views:views];
    [self addConstraints:horizontalConstraints];
    
    [self layoutIfNeeded];
    
    _searchViewControllerView.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{
        _searchViewControllerView.alpha = 1;
    }];
}

- (void)dismissSearchViewControllerView
{
    [UIView animateWithDuration:0.2 animations:^{
        _searchViewControllerView.alpha = 0;
    } completion:^(BOOL finished) {
        [_searchViewControllerView removeFromSuperview];
        _searchViewControllerView = nil;
    }];
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

#pragma mark NSNtoficationCenter target methods

- (void)keyboardWillShow:(NSNotification *)note
{
    NSDictionary* keyboardInfo = [note userInfo];
    NSValue* keyboardFrameEnd = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameEndRect = [keyboardFrameEnd CGRectValue];
    
    _searchViewControllerViewBottomConstraint.constant = -keyboardFrameEndRect.size.height;
    
    [UIView animateWithDuration:0.2 animations:^{
        [self layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)note
{
    _searchViewControllerViewBottomConstraint.constant = 0;
    
    [UIView animateWithDuration:0.2 animations:^{
        [self layoutIfNeeded];
    }];
}

#pragma mark - UIButton target methods

- (void)notificationPressed:(id)sender
{
    _listNotificationButton.selected = !_listNotificationButton.selected;
    [_delegate notificationEnabled:_listNotificationButton.selected];
}

#pragma mark - UITextField target methods

- (void)searchFieldChanged:(UITextField *)sender
{
    NSString *text = [sender.text length] ? sender.text : nil;
    
    if ((_lastFilterText == text) || ([_lastFilterText isEqualToString:text]))
        return;
    
    [_delegate filterList:text];
    
    _lastFilterText = text;
}

#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [_delegate filterList:_searchField.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

@end
