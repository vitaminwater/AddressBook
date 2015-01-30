//
//  CCMetaButtonsView.m
//  Linotte
//
//  Created by stant on 29/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import "CCActionButtonsView.h"

#import "CCFlatColorButton.h"

#import "CCMetaContainerView.h"
#import "CCActionViewContainer.h"

@interface CCActionItem : NSObject

@property(nonatomic, strong)UIView *actionView;
@property(nonatomic, assign)BOOL fullWidth;
@property(nonatomic, assign)CGFloat minHeight;

@end

@implementation CCActionItem

@end

@implementation CCActionButtonsView
{
    __weak UIView *_actionViewParent;
    CCActionViewContainer *_actionViewContainer;
    
    NSMutableArray *_buttons;
    NSMutableArray *_actionItems;
    NSInteger _currentActionIndex;
    
    NSMutableArray *_constraints;
    NSMutableArray *_actionViewConstraints;
}

- (instancetype)initWithActionViewParent:(UIView *)actionViewParent
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _currentActionIndex = -1;
        _actionViewParent = actionViewParent;
        _buttons = [@[] mutableCopy];
        _actionItems = [@[] mutableCopy];
    }
    return self;
}

- (void)addActionWithView:(UIView *)actionView fullWidth:(BOOL)fullWidth minHeight:(CGFloat)minHeight icon:(UIImage *)icon
{
    CCFlatColorButton *button = [CCFlatColorButton new];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [button setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.7] forState:UIControlStateHighlighted];
    [button setImage:icon forState:UIControlStateNormal];
    [button addTarget:self action:@selector(actionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = 4;
    button.imageView.contentMode = UIViewContentModeCenter;
    [self addSubview:button];
    [_buttons addObject:button];
    
    CCActionItem *actionItem = [CCActionItem new];
    actionItem.actionView = actionView;
    actionItem.fullWidth = fullWidth;
    actionItem.minHeight = minHeight;
    [_actionItems addObject:actionItem];
}

- (void)showActionView:(NSUInteger)index
{
    CCActionItem *actionItem = _actionItems[index];
    _currentActionIndex = index;

    if (_actionViewContainer == nil) {
        _actionViewContainer = [CCActionViewContainer new];
        _actionViewContainer.translatesAutoresizingMaskIntoConstraints = NO;
        [_actionViewContainer setupActionView:actionItem.actionView];
        [_actionViewParent addSubview:_actionViewContainer];
        
        UIButton *actionButton = _buttons[index];
        CGRect initialFrame = actionButton.frame;
        initialFrame.origin.x += self.frame.origin.x;
        initialFrame.origin.y += self.frame.origin.y;
        _actionViewContainer.frame = initialFrame;
        
        _actionViewContainer.alpha = 0;
        [self setupLayout];
        [UIView animateWithDuration:0.2 animations:^{
            _actionViewContainer.alpha = 1;
            [_actionViewParent layoutIfNeeded];
        }];
    } else {
        [_actionViewContainer setupActionView:actionItem.actionView];
        [self setupLayout];
        [UIView animateWithDuration:0.2 animations:^{
            _actionViewContainer.alpha = 1;
            [_actionViewParent layoutIfNeeded];
        }];
    }
}

- (void)removeActionView
{
    _currentActionIndex = -1;
    [self setupLayout];
    
    if (_actionViewContainer == nil)
        return;
    [UIView animateWithDuration:0.2 animations:^{
        _actionViewContainer.alpha = 0;
        [_actionViewParent layoutIfNeeded];
    } completion:^(BOOL finished) {
        [_actionViewContainer removeFromSuperview];
        _actionViewContainer = nil;
    }];
}

- (void)setupLayout
{
    if ([_constraints count])
        [self removeConstraints:_constraints];
    _constraints = [@[] mutableCopy];

    {
        NSMutableDictionary *views = [@{} mutableCopy];
        
        NSUInteger index = 0;
        NSMutableString *format = [@"V:|" mutableCopy];
        for (UIView *button in _buttons) {
            NSString *key = [NSString stringWithFormat:@"view%d", (unsigned int)index];
            [views setValue:button forKey:key];
            if (index != 0)
                [format appendString:@"-"];
            [format appendFormat:@"[%@(==45)]", key];
            
            NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|%@[view]-|", _currentActionIndex == index ? @"" : @"-"] options:0 metrics:nil views:@{@"view" : button}];
            [_constraints addObjectsFromArray:horizontalConstraints];
            ++index;
        }
        [format appendString:@"|"];
        
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:0 views:views];
        [_constraints addObjectsFromArray:verticalConstraints];
        
        [self addConstraints:_constraints];
    }
    
    if (_currentActionIndex < 0)
        return;
    
    if ([_actionViewConstraints count])
        [_actionViewParent removeConstraints:_actionViewConstraints];
    
    _actionViewConstraints = [@[] mutableCopy];
    
    if (_actionViewContainer == nil)
        return;
    
    {
        CCActionItem *actionItem = _actionItems[_currentActionIndex];
        NSDictionary *views = NSDictionaryOfVariableBindings(_actionViewContainer, self);
        
        NSString *horizontalConstraintsFormat;
        if (actionItem.fullWidth)
            horizontalConstraintsFormat = @"H:|-[_actionViewContainer][self]";
        else
            horizontalConstraintsFormat = @"H:|-(>=8)-[_actionViewContainer][self]";
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:horizontalConstraintsFormat options:0 metrics:nil views:views];
        [_actionViewConstraints addObjectsFromArray:horizontalConstraints];
        
        NSString *verticalConstraintsFormat;
        NSDictionary *verticalConstraintsMetrics;
        if (actionItem.minHeight > 0) {
            verticalConstraintsFormat = @"V:|-(==5)-[_actionViewContainer(==minHeight)]";
            verticalConstraintsMetrics = @{@"minHeight" : @(actionItem.minHeight)};
        } else {
            verticalConstraintsFormat = @"V:|-(==5)-[_actionViewContainer]";
            verticalConstraintsMetrics = @{};
        }
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:verticalConstraintsFormat options:0 metrics:verticalConstraintsMetrics views:views];
        [_actionViewConstraints addObjectsFromArray:verticalConstraints];
        
        [_actionViewParent addConstraints:_actionViewConstraints];
    }
}

#pragma mark - UIButton target methods

- (void)actionButtonPressed:(id)sender
{
    NSUInteger index = [_buttons indexOfObject:sender];
    
    if (index == _currentActionIndex) {
        [self removeActionView];
    } else {
        [self showActionView:index];
    }
}

#pragma mark - NSNotificationCenter target methods

- (void)keyboardWillShowNotification:(NSNotification *)notification
{
    /*NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameEnd = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameEndRect = [keyboardFrameEnd CGRectValue];
    
    // move bottom constraint
     
    [UIView animateWithDuration:0.2 animations:^{
        [self layoutIfNeeded];
    }];*/
}

@end
