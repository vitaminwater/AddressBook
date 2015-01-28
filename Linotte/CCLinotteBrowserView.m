//
//  CCLinotteBrowserView.m
//  Linotte
//
//  Created by stant on 06/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import "CCLinotteBrowserView.h"

@implementation CCLinotteBrowserView
{
    UIView *_topBar;
    UIView *_bottomBar;
    UIWebView *_webView;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self setupTopButtons];
        [self setupBottomButtons];
        [self setupWebView];
        [self setupLayout];
    }
    return self;
}

- (void)setupTopButtons
{
    _topBar = [UIView new];
    _topBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_topBar];
    
    UIButton *closeButton = [UIButton new];
    closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [closeButton setTitle:@"Close" forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_topBar addSubview:closeButton];
    
    // UIButton *closeButton
    {
        NSLayoutConstraint *sideConstraint = [NSLayoutConstraint constraintWithItem:closeButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_topBar attribute:NSLayoutAttributeLeft multiplier:1 constant:10];
        [_topBar addConstraint:sideConstraint];
        
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view" : closeButton}];
        [_topBar addConstraints:verticalConstraints];
    }
}

- (void)setupBottomButtons
{
    _bottomBar = [UIView new];
    _bottomBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_bottomBar];

    UIButton *backButton = [UIButton new];
    backButton.translatesAutoresizingMaskIntoConstraints = NO;
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomBar addSubview:backButton];
    
    UIButton *forwardButton = [UIButton new];
    forwardButton.translatesAutoresizingMaskIntoConstraints = NO;
    [forwardButton setTitle:@"Next" forState:UIControlStateNormal];
    [forwardButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [forwardButton addTarget:self action:@selector(forwardButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomBar addSubview:forwardButton];
    
    // UIButton *backButton
    {
        NSLayoutConstraint *sideConstraint = [NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_bottomBar attribute:NSLayoutAttributeLeft multiplier:1 constant:10];
        [_bottomBar addConstraint:sideConstraint];
        
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view" : backButton}];
        [_bottomBar addConstraints:verticalConstraints];
    }

    // UIButton *forwardButton
    {
        NSLayoutConstraint *sideConstraint = [NSLayoutConstraint constraintWithItem:forwardButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_bottomBar attribute:NSLayoutAttributeRight multiplier:1 constant:-10];
        [_bottomBar addConstraint:sideConstraint];
        
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view" : forwardButton}];
        [_bottomBar addConstraints:verticalConstraints];
    }
}

- (void)setupWebView
{
    _webView = [UIWebView new];
    _webView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_webView];
}

- (void)setupLayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_topBar, _bottomBar, _webView);
    
    [_topBar setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [_bottomBar setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==20)-[_topBar(==30)]-[_webView]-[_bottomBar(==30)]|" options:0 metrics:nil views:views];
    [self addConstraints:verticalConstraints];
    
    for (UIView *view in views.allValues) {
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
        [self addConstraints:horizontalConstraints];
    }
}

- (void)loadRootUrl:(NSString *)rootUrl
{
    NSURL *url = [NSURL URLWithString:rootUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
}

#pragma mark - UIButton target methods

- (void)backButtonPressed:(id)sender
{
    [_webView goBack];
}

- (void)forwardButtonPressed:(id)sender
{
    [_webView goForward];
}

- (void)closeButtonPressed:(id)sender
{
    [_delegate closeButtonPressed];
}

@end
