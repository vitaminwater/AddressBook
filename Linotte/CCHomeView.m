//
//  CCMainView.m
//  Linotte
//
//  Created by stant on 07/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCHomeView.h"

#import <HexColors/HexColor.h>

#import "CCLinotteField.h"

#import "CCAnimationDelegator.h"

#import "CCListOptionContainer.h"

#import "CCFlatColorButton.h"

#define kCCMainViewTopListConstraintAnimator @"kCCMainViewTopListConstraintAnimator"
#define kCCHomeViewMetrics @{@"kCCHomeButtonContainerHeight" : @45}
#define kCCHomeSearchFieldHeight [kCCLinotteTextFieldHeight floatValue]

@implementation CCHomeView
{
    UITextField *_searchField;
    UIView *_listView;
    UIView *_searchViewControllerView;
    
    NSString *_lastFilterText;
    
    CCAnimationDelegator *_animationDelegator;

    CCListOptionContainer *_buttonContainer;

    NSMutableArray *_constraints;
}

- (instancetype)initWithListView:(UIView *)listView animationDelegator:(CCAnimationDelegator *)animatorDelegator
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.opaque = YES;

        _listView = listView;
        _animationDelegator = animatorDelegator;
        [self setupSearchField];
        [self setupButtons];
        [self setupListView];
        [self setupLayout];
    }
    return self;
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

- (void)setupButtons
{
    _buttonContainer = [CCListOptionContainer new];
    _buttonContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_buttonContainer];
    
    [_buttonContainer addButtonWithIcon:nil title:NSLocalizedString(@"MY_ADDRESSES", @"") titleColor:[UIColor colorWithHexString:@"#ffae64"] target:self action:@selector(listOptionButtonPressed:)];
    [_buttonContainer addButtonWithIcon:nil title:NSLocalizedString(@"MY_BOOKS", @"") titleColor:[UIColor colorWithHexString:@"#f4607c"] target:self action:@selector(listOptionButtonPressed:)];
    [_buttonContainer addButtonWithIcon:nil title:NSLocalizedString(@"LAST_NOTIFICATIONS", @"") titleColor:[UIColor colorWithHexString:@"#5acfc4"] target:self action:@selector(listOptionButtonPressed:)];
    
    UIButton *firstButton = _buttonContainer.buttons[0];
    firstButton.selected = YES;
}

- (void)setupListView
{
    _listView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_listView];
}

- (void)setupLayout
{
    if (_constraints)
        [self removeConstraints:_constraints];
    _constraints = [@[] mutableCopy];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_searchField, _buttonContainer, _listView);

    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_searchField][_buttonContainer(kCCHomeButtonContainerHeight)][_listView]|" options:0 metrics:kCCHomeViewMetrics views:views];
    [_constraints addObjectsFromArray:verticalConstraints];
    
    NSLayoutConstraint *searchHeightConstraint = [NSLayoutConstraint constraintWithItem:_searchField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:0];
    [self addConstraint:searchHeightConstraint];
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(_searchField) weakSearchField = _searchField;
    [_animationDelegator setTimeLineAnimationItemForKey:kCCMainViewTopListConstraintAnimator animationBlock:^BOOL(CGFloat value) {
        if (value > 0) {
            if (searchHeightConstraint.constant >= kCCHomeSearchFieldHeight) {
                return NO;
            }
            searchHeightConstraint.constant = MIN(kCCHomeSearchFieldHeight, searchHeightConstraint.constant + value);
            [weakSelf layoutIfNeeded];
            return YES;
        } else {
            if (searchHeightConstraint.constant <= 0)
                return NO;
            [weakSearchField resignFirstResponder];
            searchHeightConstraint.constant = MAX(0, searchHeightConstraint.constant + value);
            [weakSelf layoutIfNeeded];
            return YES;
        }
        return NO;
    } fingerLiftBlock:^(){
        if (searchHeightConstraint.constant >= kCCHomeSearchFieldHeight / 2) {
            //[weakSearchField becomeFirstResponder];
            searchHeightConstraint.constant = kCCHomeSearchFieldHeight;
        } else {
            //[weakSearchField resignFirstResponder];
            searchHeightConstraint.constant = 0;
        }
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:1 options:0 animations:^{
            [weakSelf layoutIfNeeded];
        } completion:^(BOOL finished){
        }];
    }];
    
    for (UIView *view in views.allValues) {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
        [_constraints addObjectsFromArray:horizontalConstraints];
    }
    
    [self addConstraints:_constraints];
}

- (void)searchFieldResignFirstResponder
{
    [_searchField resignFirstResponder];
}

- (void)setSelectedButtonAtIndex:(NSUInteger)index
{
    UIButton *listOptionButton = (UIButton *)_buttonContainer.buttons[index];
    [self listOptionButtonPressed:listOptionButton];
}

- (void)presentSearchViewControllerView:(UIView *)searchViewControllerView
{
    _searchViewControllerView = searchViewControllerView;
    _searchViewControllerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_searchViewControllerView];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_searchField, _searchViewControllerView);
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_searchField][_searchViewControllerView]|" options:0 metrics:nil views:views];
    [self addConstraints:verticalConstraints];
    
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

#pragma mark - UIButton target methods

- (void)listOptionButtonPressed:(UIButton *)pressedButton
{
    if (pressedButton.selected)
        return;
    
    NSUInteger index = [_buttonContainer.buttons indexOfObject:pressedButton];
    [_delegate homePanelSelected:index];
    for (UIButton *button in _buttonContainer.buttons) {
        button.selected = button == pressedButton;
    }
    [_searchField resignFirstResponder];
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
    if ([_searchField.text length] != 0)
        [_delegate filterList:_searchField.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

@end
