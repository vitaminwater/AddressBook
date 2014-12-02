//
//  CCSwapperViewController.m
//  Linotte
//
//  Created by stant on 30/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCSwapperViewController.h"

#import "CCSwapperView.h"

@implementation CCSwapperViewController
{
    UIViewController *_firstViewController;
}

- (instancetype)initWithFirstViewController:(UIViewController *)firstViewController
{
    self = [super init];
    if (self) {
        _firstViewController = firstViewController;
        _currentViewController = firstViewController;
    }
    return self;
}

- (void)loadView
{
    [self addChildViewController:_firstViewController];
    CCSwapperView *view = [[CCSwapperView alloc] initWithFirstView:_firstViewController.view];
    view.delegate = self;
    self.view = view;
    [_firstViewController didMoveToParentViewController:self];
}

- (void)swapToViewController:(UIViewController *)viewController
{
    if (viewController == _currentViewController)
        return;
    
    CCSwapperView *view = (CCSwapperView *)self.view;
    
    [_currentViewController willMoveToParentViewController:nil];
    [self addChildViewController:viewController];
    UIViewController *currentViewController = _currentViewController;
    _currentViewController = viewController;
    
    [view swapCurrentViewWithView:viewController.view completionBlock:^{
        [viewController didMoveToParentViewController:viewController];
        [currentViewController removeFromParentViewController];
    }];
}

@end
