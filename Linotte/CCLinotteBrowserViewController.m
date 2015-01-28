//
//  CCLinotteBrowserViewController.m
//  Linotte
//
//  Created by stant on 06/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import "CCLinotteBrowserViewController.h"

#import "CCLinotteBrowserView.h"

@implementation CCLinotteBrowserViewController
{
    NSString *_rootUrl;
}

- (instancetype)initWithRootUrl:(NSString *)rootUrl
{
    self = [super init];
    if (self) {
        _rootUrl = rootUrl;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    CCLinotteBrowserView *view = [CCLinotteBrowserView new];
    view.delegate = self;
    self.view = view;
    
    [view loadRootUrl:_rootUrl];
}

#pragma mark - CCLinotteBrowserViewDelegate methods

- (void)closeButtonPressed
{
    [_delegate closeBrowserViewController];
}

@end
