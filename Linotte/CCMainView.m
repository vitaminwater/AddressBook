//
//  CCMainView.m
//  Linotte
//
//  Created by stant on 07/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCMainView.h"

#import <HexColors/HexColor.h>

#import "CCListOptionContainer.h"

#import "CCFlatColorButton.h"

#define kCCStatusBarHeight @20

@interface CCMainView()
{
    UIView *_addView;
    UIView *_listView;
}

@property(nonatomic, strong)CCListOptionContainer *buttonContainer;
@property(nonatomic, assign)CGFloat panVelocity;

@end

@implementation CCMainView

- (id)init
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
    UIView *statusBar = [UIView new];
    statusBar.backgroundColor = [UIColor colorWithHexString:@"#6b6b6b"];
    statusBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:statusBar];
    
    CGRect bounds = self.bounds;
    CGRect frame = CGRectMake(0, 0, bounds.size.width, [kCCStatusBarHeight doubleValue]);
    statusBar.frame = frame;
}

- (void)setupButtons
{
    _buttonContainer = [CCListOptionContainer new];
    _buttonContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_buttonContainer];
    
    [_buttonContainer addButtonWithIcon:[UIImage imageNamed:@"discover"] title:NSLocalizedString(@"DISCOVER_LIST", @"") titleColor:[UIColor colorWithHexString:@"#ffae64"] target:self action:@selector(discoverPressed:)];
    [_buttonContainer addButtonWithIcon:[UIImage imageNamed:@"book_pink"] title:NSLocalizedString(@"MY_LISTS", @"") titleColor:[UIColor colorWithHexString:@"f4607c"] target:self action:@selector(myListsPressed:)];
}

- (void)setupAddView:(UIView *)addView
{
    _addView = addView;
    
    _addView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_addView];
}

- (void)setupListView:(UIView *)listView
{
    NSAssert(_addView != nil, kCCWrongSetupMethodsOrderError);
    
    _listView = listView;
    
    _listView.translatesAutoresizingMaskIntoConstraints = NO;
    [self insertSubview:_listView belowSubview:_addView];
}

- (void)setupLayout
{
    [self removeConstraints:self.constraints];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_addView, _buttonContainer, _listView);
    // Add view
    {
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:_addView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:[kCCStatusBarHeight doubleValue]];
        [self addConstraint:topConstraint];
        
        if (_addViewExpanded) {
            NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:_addView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:-[kCCAddViewKeyboardHeight doubleValue]];
            [self addConstraint:bottomConstraint];
        } else {
            NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:_addView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:[kCCAddViewTextFieldHeight doubleValue]];
            [self addConstraint:heightConstraint];
        }
    }
    
    // Button container
    {
        if (_addViewExpanded) {
            NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:_buttonContainer attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:[kCCAddViewTextFieldHeight doubleValue]];
            [self addConstraint:topConstraint];
        } else {
            NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:_buttonContainer attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_addView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
            [self addConstraint:topConstraint];
        }
    }
    
    // _listView
    {
        if (_optionViewExpanded) {
            NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:_listView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_buttonContainer attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
            [self addConstraint:topConstraint];
        } else {
            NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:_listView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_buttonContainer attribute:NSLayoutAttributeTop multiplier:1 constant:4];
            [self addConstraint:topConstraint];
        }
        
        NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:_listView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        [self addConstraint:bottomConstraint];
    }
    
    for (UIView *view in views.allValues) {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
        [self addConstraints:horizontalConstraints];
    }
}

#pragma mark - UIbutton target methods

- (void)myListsPressed:(UIButton *)sender
{
    [_delegate showListList];
}

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

- (void)setOptionViewExpanded:(BOOL)optionViewExpanded
{
    if (_optionViewExpanded == optionViewExpanded)
        return;
    
    [self willChangeValueForKey:@"optionViewExpanded"];
    _optionViewExpanded = optionViewExpanded;
    [self setupLayout];
    
    [UIView animateWithDuration:0.2 animations:^{
        [self layoutIfNeeded];
    }];
    
    [self didChangeValueForKey:@"optionViewExpanded"];
}

@end
