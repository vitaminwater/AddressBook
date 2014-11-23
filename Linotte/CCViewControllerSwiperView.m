//
//  CCViewControllerSwiperView.m
//  Linotte
//
//  Created by stant on 23/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCViewControllerSwiperView.h"

@implementation CCViewControllerSwiperView
{
    NSArray *_viewControllerViews;
    NSUInteger _currentViewIndex;
    
    UIScreenEdgePanGestureRecognizer *_prevGestureRecognizer;
    UIScreenEdgePanGestureRecognizer *_nextGestureRecognizer;
    
    NSLayoutConstraint *_centerXConstraint;
}

- (instancetype)initWithViewControllerViews:(NSArray *)viewControllerViews
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self setupGestureRecognizers];
        [self setupViewControllerViews:viewControllerViews];
        [self setupLayout];
    }
    return self;
}

- (void)setupGestureRecognizers
{
    _prevGestureRecognizer = [UIScreenEdgePanGestureRecognizer new];
    _prevGestureRecognizer.edges = UIRectEdgeLeft;
    [_prevGestureRecognizer addTarget:self action:@selector(screenEdgeGestureRecognizer:)];
    _prevGestureRecognizer.delegate = self;
    [self addGestureRecognizer:_prevGestureRecognizer];
    
    _nextGestureRecognizer = [UIScreenEdgePanGestureRecognizer new];
    _nextGestureRecognizer.edges = UIRectEdgeRight;
    [_nextGestureRecognizer addTarget:self action:@selector(screenEdgeGestureRecognizer:)];
    _nextGestureRecognizer.delegate = self;
    [self addGestureRecognizer:_nextGestureRecognizer];
}

- (void)setupViewControllerViews:(NSArray *)viewControllerViews
{
    _viewControllerViews = viewControllerViews;
    
    for (UIView *viewControllerView in viewControllerViews) {
        viewControllerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:viewControllerView];
    }
}

- (void)setupLayout
{
    for (int i = 1; i < [_viewControllerViews count]; ++i) {
        UIView *previous = _viewControllerViews[i - 1];
        UIView *current = _viewControllerViews[i];
        
        NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:previous attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:current attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        [self addConstraint:rightConstraint];
    }

    for (UIView *viewControllerView in _viewControllerViews) {
        NSDictionary *views = @{@"view" : viewControllerView, @"parent" : self};
        
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:views];
        [self addConstraints:verticalConstraints];
        
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==parent)]" options:0 metrics:nil views:views];
        [self addConstraints:horizontalConstraints];
    }
    
    [self setCenterConstraint:0];
}

- (void)setCenterConstraint:(NSUInteger)viewControllerIndex
{
    if (_centerXConstraint != nil)
        [self removeConstraint:_centerXConstraint];
    
    UIView *view = _viewControllerViews[viewControllerIndex];
    
    _centerXConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    [self addConstraint:_centerXConstraint];
}

#pragma mark - UIGestureRecognizer delegate methods

- (void)screenEdgeGestureRecognizer:(UIScreenEdgePanGestureRecognizer *)edgeSwipeGestureRecognizer
{
    CGPoint translation = [edgeSwipeGestureRecognizer translationInView:self];
    
    if (edgeSwipeGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
    } else if (edgeSwipeGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat divider = 1.0f;
        
        if ((edgeSwipeGestureRecognizer == _nextGestureRecognizer && _centerXConstraint.constant < 0)
            || (edgeSwipeGestureRecognizer == _prevGestureRecognizer && _centerXConstraint.constant > 0))
            divider = 2.5f;
        
        _centerXConstraint.constant = translation.x / divider;
    } else if (edgeSwipeGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGRect bounds = self.bounds;
        CGPoint velocity = [edgeSwipeGestureRecognizer velocityInView:self];
        BOOL goingNext = edgeSwipeGestureRecognizer == _nextGestureRecognizer;
        BOOL cancelled = (goingNext == YES ? _currentViewIndex >= [_viewControllerViews count] - 1 : _currentViewIndex == 0)
                        || (
                                (velocity.x * (goingNext == YES ? -1 : 1) < 800)
                                && (fabs(translation.x) < bounds.size.width / 2)
                    );
        
        if (cancelled)
            _centerXConstraint.constant = 0;
        else {
            _currentViewIndex += (goingNext ? 1 : -1);
            [self setCenterConstraint:_currentViewIndex];
        }
        [UIView animateWithDuration:0.5     delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0.5 options:0 animations:^{
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
    }
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

@end
