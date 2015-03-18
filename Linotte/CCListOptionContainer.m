//
//  CCListOptionContainer.m
//  Linotte
//
//  Created by stant on 15/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListOptionContainer.h"

#import <HexColors/HexColor.h>

#import "CCListOptionButton.h"
#import "CCTabStyleButton.h"


@implementation CCListOptionContainer
{
    UIScrollView *_scrollView;
    UIView *_contentView;
    UIPageControl *_pageControl;
    
    NSLayoutConstraint *_pageControlHeight;
    
    NSMutableArray *_buttons;
}

@synthesize buttons = _buttons;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.opaque = YES;
        _buttons = [@[] mutableCopy];
        
        [self setupScrollView];
        [self setupContentView];
        [self setupPageControl];
        [self setupLayout];
    }
    return self;
}

- (void)setupScrollView
{
    _scrollView = [UIScrollView new];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    //_scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    [self addSubview:_scrollView];
}

- (void)setupContentView
{
    _contentView = [UIView new];
    _contentView.translatesAutoresizingMaskIntoConstraints = NO;
    _contentView.userInteractionEnabled = YES;
    [_scrollView addSubview:_contentView];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_contentView, _scrollView);
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_contentView]|" options:0 metrics:nil views:views];
    [_scrollView addConstraints:horizontalConstraints];
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_contentView(==_scrollView)]|" options:0 metrics:nil views:views];
    [_scrollView addConstraints:verticalConstraints];
}

- (void)setupPageControl
{
    _pageControl = [UIPageControl new];
    _pageControl.hidesForSinglePage = YES;
    _pageControl.translatesAutoresizingMaskIntoConstraints = NO;
    _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    _pageControl.currentPageIndicatorTintColor = [UIColor colorWithHexString:@"#5acfc4"];
    [_pageControl addTarget:self action:@selector(pageControl:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_pageControl];
}

- (void)setupLayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_scrollView, _pageControl);
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView][_pageControl]|" options:0 metrics:nil views:views];
    [self addConstraints:verticalConstraints];
    
    _pageControlHeight = [NSLayoutConstraint constraintWithItem:_pageControl attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:0];
    [self addConstraint:_pageControlHeight];
    
    for (UIView *view in views.allValues) {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
        [self addConstraints:horizontalConstraints];
    }
}

- (void)addButtonWithIcon:(UIImage *)icon title:(NSString *)title titleColor:(UIColor *)titleColor target:(id)target action:(SEL)action
{
    CCTabStyleButton *button;
    
    if (icon != nil)
        button = [CCListOptionButton new];
    else
        button = [CCTabStyleButton new];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button setTitleColor:titleColor forState:UIControlStateNormal];

    if (icon != nil) {
        [button setImage:icon forState:UIControlStateNormal];
        button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:19];
    [button setBackgroundColor:[UIColor whiteColor]];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    [_contentView addSubview:button];
    [_buttons addObject:button];
    
    _pageControl.numberOfPages = ceil([_buttons count] / 2);
    
    _pageControlHeight.constant = _pageControl.numberOfPages > 1 ? 20 : 0;
    
    [self setupConstraintsForButtons];
}

- (void)setupConstraintsForButtons
{
    [_contentView removeConstraints:_contentView.constraints];
    
    NSMutableString *formatString = [@"H:|" mutableCopy];
    NSMutableDictionary *views = [@{} mutableCopy];
    
    int i = 0;
    for (UIButton *button in _buttons) {
        NSString *buttonName = [NSString stringWithFormat:@"button%d", i];
        [formatString appendFormat:@"[%@]", buttonName];
        views[buttonName] = button;
        ++i;
    }
    
    [formatString appendString:@"|"];
    
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:formatString options:0 metrics:nil views:views];
    [_contentView addConstraints:horizontalConstraints];

    for (UIView *view in views.allValues) {
        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_scrollView attribute:NSLayoutAttributeWidth multiplier:0.5 constant:-20];
        [_scrollView addConstraint:widthConstraint];
        
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
        [_contentView addConstraints:verticalConstraints];
    }
}

#pragma mark - UIControl target methods

- (void)pageControl:(UIPageControl *)pageControl
{
    CGRect visibleRect = _scrollView.bounds;
    visibleRect.origin.x = pageControl.currentPage * _scrollView.bounds.size.width;
    [_scrollView scrollRectToVisible:visibleRect animated:YES];
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _pageControl.currentPage = ceil(scrollView.contentOffset.x / scrollView.bounds.size.width);
}

@end
