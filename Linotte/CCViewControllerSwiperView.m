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
    
    UIView *_titleView;
    UILabel *_titleLabel;
    UIPageControl *_pageControl;
    
    UIGestureRecognizer *_prevGestureRecognizer;
    UIGestureRecognizer *_nextGestureRecognizer;
    
    BOOL _edgeOnly;

    NSLayoutConstraint *_centerXConstraint;
    
    BOOL _cancelledHideTitle;
}

- (instancetype)initWithViewControllerViews:(NSArray *)viewControllerViews edgeOnly:(BOOL)edgeOnly
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _edgeOnly = edgeOnly;
        [self setupGestureRecognizers];
        [self setupViewControllerViews:viewControllerViews];
        [self setupTitleLabel];
        [self setupLayout];
    }
    return self;
}

- (void)setupGestureRecognizers
{
    if (_edgeOnly) {
        UIScreenEdgePanGestureRecognizer *prevGestureRecognizer = [UIScreenEdgePanGestureRecognizer new];
        prevGestureRecognizer.edges = UIRectEdgeLeft;
        [self addGestureRecognizer:prevGestureRecognizer];
        
        UIScreenEdgePanGestureRecognizer *nextGestureRecognizer = [UIScreenEdgePanGestureRecognizer new];
        nextGestureRecognizer.edges = UIRectEdgeRight;
        [self addGestureRecognizer:nextGestureRecognizer];
        _prevGestureRecognizer = prevGestureRecognizer;
        _nextGestureRecognizer = nextGestureRecognizer;
    } else {
        UIPanGestureRecognizer *prevGestureRecognizer = [UIPanGestureRecognizer new];
        [self addGestureRecognizer:prevGestureRecognizer];
        _prevGestureRecognizer = prevGestureRecognizer;
        _nextGestureRecognizer = nil;
    }
    [_prevGestureRecognizer addTarget:self action:@selector(screenEdgeGestureRecognizer:)];
    _prevGestureRecognizer.delegate = self;
    [_nextGestureRecognizer addTarget:self action:@selector(screenEdgeGestureRecognizer:)];
    _nextGestureRecognizer.delegate = self;
}

- (void)setupViewControllerViews:(NSArray *)viewControllerViews
{
    _viewControllerViews = viewControllerViews;
    
    for (UIView *viewControllerView in viewControllerViews) {
        viewControllerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:viewControllerView];
    }
}

- (void)setupTitleLabel
{
    _titleView = [UIView new];
    _titleView.translatesAutoresizingMaskIntoConstraints = NO;
    _titleView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [self addSubview:_titleView];
    
    _titleLabel = [UILabel new];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:23];
    _titleLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.numberOfLines = 0;
    [_titleView addSubview:_titleLabel];
    
    _pageControl = [UIPageControl new];
    _pageControl.translatesAutoresizingMaskIntoConstraints = NO;
    _pageControl.numberOfPages = [_viewControllerViews count];
    [_titleView addSubview:_pageControl];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_titleLabel, _pageControl);
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_titleLabel][_pageControl(==10)]-(==5)-|" options:0 metrics:nil views:views];
    [_titleView addConstraints:verticalConstraints];
    
    for (UIView *view in views.allValues) {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
        [self addConstraints:horizontalConstraints];
    }
    
    _titleView.alpha = 0;
    _titleView.hidden = YES;
}

- (void)setupLayout
{
    {
        NSDictionary *views = NSDictionaryOfVariableBindings(_titleView);
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_titleView]|" options:0 metrics:nil views:views];
        [self addConstraints:horizontalConstraints];
        
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_titleView]" options:0 metrics:nil views:views];
        [self addConstraints:verticalConstraints];
    }
    
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
    CGRect bounds = self.bounds;
    CGPoint translation = [edgeSwipeGestureRecognizer translationInView:self];
    BOOL goingNext = [self goingNext:edgeSwipeGestureRecognizer translation:translation];
    BOOL limit = (goingNext && _currentViewIndex >= [_viewControllerViews count] - 1)
                  || (goingNext == NO && _currentViewIndex == 0);
    
    if (edgeSwipeGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        if (limit == NO) {
            _titleLabel.text = [_delegate nameForViewControllerAtIndex:_currentViewIndex];
            [self showTitleLabel];
        }
    } else if (edgeSwipeGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat divider = 1.0f;
        
        if (limit == YES)
            divider = 2.5f;
        else {
            if (fabs(translation.x) > bounds.size.width / 2) {
                NSString *nextTitle = [_delegate nameForViewControllerAtIndex:_currentViewIndex + (goingNext ? 1 : -1)];
                [self setTitle:nextTitle];
                _pageControl.currentPage = _currentViewIndex + (goingNext ? 1 : -1);
            } else {
                [self setTitle:[_delegate nameForViewControllerAtIndex:_currentViewIndex]];
                _pageControl.currentPage = _currentViewIndex;
            }
        }
        
        _centerXConstraint.constant = translation.x / divider;

    } else if (edgeSwipeGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [edgeSwipeGestureRecognizer velocityInView:self];
        BOOL cancelled = limit
                        || (
                                (velocity.x * (goingNext == YES ? -1 : 1) < 800)
                                && (fabs(translation.x) < bounds.size.width / 2)
                    );
        
        if (cancelled) {
            _centerXConstraint.constant = 0;
            [self setTitle:@"X"];
            [self hideTitleLabelAfterDelay:0];
        } else {
            _currentViewIndex += (goingNext ? 1 : -1);
            [self setCenterConstraint:_currentViewIndex];
            [_delegate currentViewControllerChangedToIndex:_currentViewIndex];
            
            [self setTitle:[_delegate nameForViewControllerAtIndex:_currentViewIndex]];
            if (cancelled == NO && fabs(velocity.x) < 700)
                [self hideTitleLabelAfterDelay:0.3];
        }
        
        _pageControl.currentPage = _currentViewIndex;
        
        [self animateLayoutChange:limit animations:^{
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            if (cancelled == NO && fabs(velocity.x) > 700)
                [self hideTitleLabelAfterDelay:0.7];
        }];
    }
}

- (void)animateLayoutChange:(BOOL)springAnimation animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion
{
    if (springAnimation) {
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0.5 options:0 animations:animations completion:completion];
    } else {
        [UIView animateWithDuration:0.2 animations:animations completion:completion];
    }
}

- (BOOL)goingNext:(UIGestureRecognizer *)gestureRecognizer translation:(CGPoint)translation
{
    if (_edgeOnly)
        return gestureRecognizer == _nextGestureRecognizer;
    return translation.x < 0;
}

- (void)setTitle:(NSString *)title
{
    _cancelledHideTitle = YES;
    _titleLabel.text = title;
}

- (void)showTitleLabel
{
    _cancelledHideTitle = YES;
    _titleView.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        _titleView.alpha = 1;
    }];
}

- (void)hideTitleLabelAfterDelay:(NSTimeInterval)seconds
{
    _cancelledHideTitle = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (_cancelledHideTitle)
            return;
        [UIView animateWithDuration:0.2 animations:^{
            _titleView.alpha = 0;
        } completion:^(BOOL finished) {
            if (_cancelledHideTitle)
                return;
            _titleView.hidden = YES;
        }];
    });
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

@end
