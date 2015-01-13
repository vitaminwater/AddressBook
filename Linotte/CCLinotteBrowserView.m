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
}

- (void)setupBottomButtons
{
    _bottomBar = [UIView new];
    _bottomBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_bottomBar];
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
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_topBar(==30)][_webView][_bottomBar(==_topBar)]|" options:0 metrics:nil views:views];
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

@end
