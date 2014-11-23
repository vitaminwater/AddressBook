//
//  CCMainView.m
//  Linotte
//
//  Created by stant on 07/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCMainView.h"

#import <HexColors/HexColor.h>

#import "CCAnimationDelegator.h"

#import "CCListOptionContainer.h"

#import "CCFlatColorButton.h"

#define kCCMainViewTopListConstraintAnimator @"kCCMainViewTopListConstraintAnimator"

@implementation CCMainView
{
    UIView *_statusBar;
    UIView *_addView;
    UIView *_listView;
    
    CCAnimationDelegator *_animationDelegator;

    CCListOptionContainer *_buttonContainer;
    CGFloat _panVelocity;
    
    NSMutableArray *_constraints;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self setupStatusBar];
        [self setupButtons];
    }
    return self;
}

- (void)setupStatusBar
{
    _statusBar = [UIView new];
    _statusBar.translatesAutoresizingMaskIntoConstraints = NO;
    _statusBar.backgroundColor = [UIColor colorWithHexString:@"#6b6b6b"];
    _statusBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:_statusBar];
}

- (void)setupButtons
{
    _buttonContainer = [CCListOptionContainer new];
    _buttonContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self insertSubview:_buttonContainer belowSubview:_statusBar];
    
    [_buttonContainer addButtonWithIcon:[UIImage imageNamed:@"discover"] title:NSLocalizedString(@"DISCOVER_LIST", @"") titleColor:[UIColor colorWithHexString:@"#ffae64"] target:self action:@selector(discoverPressed:)];
    //[_buttonContainer addButtonWithIcon:[UIImage imageNamed:@"book_pink"] title:NSLocalizedString(@"MY_LISTS", @"") titleColor:[UIColor colorWithHexString:@"f4607c"] target:self action:@selector(myListsPressed:)];
}

- (void)setupAddView:(UIView *)addView
{
    _addView = addView;
    _addView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_addView];
}

- (void)setupListView:(UIView *)listView animationDelegator:(CCAnimationDelegator *)animationDelegator
{
    _animationDelegator = animationDelegator;
    _listView = listView;
    _listView.translatesAutoresizingMaskIntoConstraints = NO;
    [self insertSubview:_listView belowSubview:_statusBar];
}

- (void)setupLayout
{
    if (_constraints)
        [self removeConstraints:_constraints];
    _constraints = [@[] mutableCopy];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_statusBar, _addView, _buttonContainer, _listView);
    
    // status bar
    {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_statusBar]|" options:0 metrics:nil views:views];
        [_constraints addObjectsFromArray:horizontalConstraints];
        
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_statusBar(==kCCStatusBarHeight)]" options:0 metrics:kCCAddViewTextFieldHeightMetric views:views];
        [_constraints addObjectsFromArray:verticalConstraints];
    }
    
    // Add view
    {
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:_addView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_statusBar attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        [_constraints addObject:topConstraint];
        
        if (_addViewExpanded) {
            NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:_addView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:-[kCCAddViewKeyboardHeight doubleValue]];
            [_constraints addObject:bottomConstraint];
        } else {
            NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:_addView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:[kCCAddViewTextFieldHeight doubleValue]];
            [_constraints addObject:heightConstraint];
        }
    }
    
    // Button container
    {
        if (_addViewExpanded) {
            NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:_buttonContainer attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:[kCCAddViewTextFieldHeight doubleValue] + [kCCStatusBarHeight doubleValue]];
            [_constraints addObject:topConstraint];
        } else {
            NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:_buttonContainer attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_addView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
            [_constraints addObject:topConstraint];
        }
    }
    
    // List view
    {
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:_listView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_buttonContainer attribute:NSLayoutAttributeTop multiplier:1 constant:5];
        [_constraints addObject:topConstraint];
        
        NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:_listView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        [_constraints addObject:bottomConstraint];
        
        __weak typeof(self) weakSelf = self;
        __weak typeof(_buttonContainer) weakButtonContainer = _buttonContainer;
        [_animationDelegator setTimeLineAnimationItemForKey:kCCMainViewTopListConstraintAnimator animationBlock:^BOOL(CGFloat value) {
            if (value > 0) {
                if (topConstraint.constant >= weakButtonContainer.bounds.size.height)
                    return NO;
                topConstraint.constant = MIN(weakButtonContainer.bounds.size.height, topConstraint.constant + value);
                [weakSelf layoutIfNeeded];
                return YES;
            } else {
                if (topConstraint.constant <= 5)
                    return NO;
                topConstraint.constant = MAX(5, topConstraint.constant + value);
                [weakSelf layoutIfNeeded];
                return YES;
            }
            return NO;
        } fingerLiftBlock:^(){
            if (topConstraint.constant >= weakButtonContainer.bounds.size.height / 2)
                topConstraint.constant = weakButtonContainer.bounds.size.height;
            else
                topConstraint.constant = 5;
            [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:1 options:0 animations:^{
                [weakSelf layoutIfNeeded];
            } completion:^(BOOL finished){
            }];
        }];
    }
    
    for (UIView *view in views.allValues) {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
        [_constraints addObjectsFromArray:horizontalConstraints];
    }
    
    [self addConstraints:_constraints];
}

#pragma mark - UIbutton target methods

- (void)discoverPressed:(UIButton *)sender
{
    [_delegate showListStore];
}

#pragma mark - setter methods

- (void)setAddViewExpanded:(BOOL)addViewExpanded
{
    if (_addViewExpanded == addViewExpanded)
        return;
    
    [self willChangeValueForKey:@"addViewExpanded"];
    _addViewExpanded = addViewExpanded;
    [self setupLayout];
    
    [UIView animateWithDuration:0.4 animations:^{
        [self layoutIfNeeded];
    }];
    
    [self didChangeValueForKey:@"addViewExpanded"];
}

@end
