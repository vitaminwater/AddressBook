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
    UIActivityIndicatorView *_loadingView;
    UIWebView *_webView;
    
    UIButton *_backButton;
    UIButton *_forwardButton;
    
    NSUInteger _webviewLoadings;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _webviewLoadings = 0;
        
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
    [closeButton setImage:[UIImage imageNamed:@"close_browser_icon"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    closeButton.contentMode = UIViewContentModeScaleAspectFit;
    [_topBar addSubview:closeButton];
    
    UIButton *externalButton = [UIButton new];
    externalButton.translatesAutoresizingMaskIntoConstraints = NO;
    [externalButton setImage:[UIImage imageNamed:@"icon_browser_external"] forState:UIControlStateNormal];
    [externalButton addTarget:self action:@selector(externalButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    externalButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_topBar addSubview:externalButton];
    
    _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _loadingView.translatesAutoresizingMaskIntoConstraints = NO;
    _loadingView.hidesWhenStopped = YES;
    [_topBar addSubview:_loadingView];
    
    // UIButton *closeButton, UIButton *externalButton
    {
        NSDictionary *views = NSDictionaryOfVariableBindings(externalButton, closeButton);

        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[externalButton(==40)]-[closeButton(==externalButton)]-|" options:0 metrics:nil views:views];
        [_topBar addConstraints:horizontalConstraints];
        
        for (UIView *view in views.allValues) {
            NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view" : view}];
            [_topBar addConstraints:verticalConstraints];
        }
    }
    
    // _loadingView
    {
        NSLayoutConstraint *sideConstraint = [NSLayoutConstraint constraintWithItem:_loadingView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_topBar attribute:NSLayoutAttributeLeft multiplier:1 constant:10];
        [_topBar addConstraint:sideConstraint];
        
        NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:_loadingView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_topBar attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        [_topBar addConstraint:centerYConstraint];
    }
}

- (void)setupBottomButtons
{
    _bottomBar = [UIView new];
    _bottomBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_bottomBar];

    _backButton = [UIButton new];
    _backButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_backButton setImage:[UIImage imageNamed:@"back_browser_icon"] forState:UIControlStateNormal];
    [_backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_backButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    _backButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _backButton.enabled = NO;
    [_bottomBar addSubview:_backButton];
    
    _forwardButton = [UIButton new];
    _forwardButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_forwardButton setImage:[UIImage imageNamed:@"next_browser_icon"] forState:UIControlStateNormal];
    [_forwardButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_forwardButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    _forwardButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_forwardButton addTarget:self action:@selector(forwardButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _forwardButton.enabled = NO;
    [_bottomBar addSubview:_forwardButton];
    
    // UIButton *backButton, UIButton *forwardButton
    {
        NSDictionary *views = NSDictionaryOfVariableBindings(_backButton, _forwardButton);
        
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[_backButton]-[_forwardButton]-|" options:0 metrics:nil views:views];
        [_bottomBar addConstraints:horizontalConstraints];
        
        for (UIView *view in views.allValues) {
            NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==3)-[view]-(==5)-|" options:0 metrics:nil views:@{@"view" : view}];
            [_bottomBar addConstraints:verticalConstraints];
        }
    }
}

- (void)updateNavigationButtons
{
    _backButton.enabled = [_webView canGoBack];
    _forwardButton.enabled = [_webView canGoForward];
}

- (void)setupWebView
{
    _webView = [UIWebView new];
    _webView.translatesAutoresizingMaskIntoConstraints = NO;
    _webView.scalesPageToFit = YES;
    _webView.delegate = self;
    [self addSubview:_webView];
}

- (void)setupLayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_topBar, _bottomBar, _webView);
    
    [_topBar setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [_bottomBar setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==20)-[_topBar(==30)]-[_webView]-[_bottomBar(==35)]|" options:0 metrics:nil views:views];
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

#pragma mark - UIWebViewDelegate methods

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    CCLog(@"Browser: %@", error);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    ++_webviewLoadings;
    if (_webviewLoadings == 1) {
        [_loadingView startAnimating];
    }
    [self updateNavigationButtons];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    --_webviewLoadings;
    if (_webviewLoadings == 0) {
        [_loadingView stopAnimating];
    }
    [self updateNavigationButtons];
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

- (void)externalButtonPressed:(id)sender
{
    [_delegate externalButtonPressed];
}

@end
