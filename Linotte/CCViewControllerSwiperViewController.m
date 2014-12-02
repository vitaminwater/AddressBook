//
//  CCViewControllerSwiperViewController.m
//  Linotte
//
//  Created by stant on 23/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCViewControllerSwiperViewController.h"

#import "CCViewControllerSwiperView.h"

@implementation CCViewControllerSwiperViewController
{
    BOOL _edgeOnly;
    NSUInteger _startViewControllerIndex;
}

- (instancetype)initWithViewControllers:(NSArray *)viewControllers edgeOnly:(BOOL)edgeOnly startViewControllerIndex:(NSUInteger)startViewControllerIndex
{
    self = [super init];
    if (self) {
        _viewControllers = viewControllers;
        _edgeOnly = edgeOnly;
        _startViewControllerIndex = startViewControllerIndex;
    }
    return self;
}

- (void)loadView
{
    NSArray *viewControllerViews = [_viewControllers valueForKeyPath:@"@unionOfObjects.view"];
    for (UIViewController *viewController in _viewControllers) {
        [self addChildViewController:viewController];
    }
    
    CCViewControllerSwiperView *view = [[CCViewControllerSwiperView alloc] initWithViewControllerViews:viewControllerViews edgeOnly:_edgeOnly startViewControllerViewIndex:_startViewControllerIndex];
    view.delegate = self;
    self.view = view;
    
    for (UIViewController *viewController in _viewControllers) {
        [viewController didMoveToParentViewController:self];
    }
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
}

#pragma mark - CCViewControllerSwiperViewDelegate

- (void)currentViewControllerWillChangeToIndex:(NSUInteger)index fromIndex:(NSUInteger)fromIndex
{
    if (index != fromIndex) {
        UIViewController *fromViewController = _viewControllers[fromIndex];
        [fromViewController viewWillDisappear:YES];
    }
    
    UIViewController *viewController = _viewControllers[index];
    [viewController viewWillAppear:YES];
}

- (void)currentViewControllerDidChangeToIndex:(NSUInteger)index fromIndex:(NSUInteger)fromIndex
{
    if (index != fromIndex) {
        UIViewController *fromViewController = _viewControllers[fromIndex];
        [fromViewController viewDidDisappear:YES];
        [_delegate viewControllerHidden:fromViewController];
    }
    
    UIViewController *viewController = _viewControllers[index];
    [_delegate viewControllerShown:viewController];
    [viewController viewDidAppear:YES];
}

- (NSString *)nameForViewControllerAtIndex:(NSUInteger)index
{
    UIViewController *viewController = _viewControllers[index];
    return viewController.title;
}

#pragma mark - getter methods

- (UIViewController *)currentViewController
{
    CCViewControllerSwiperView *view = (CCViewControllerSwiperView *)self.view;
    NSUInteger currentIndex = view.currentViewIndex;
    UIViewController *viewController = _viewControllers[currentIndex];
    
    return viewController;
}

#pragma mark - setter methods

- (void)setCurrentViewControllerIndex:(NSUInteger)currentViewController
{
    CCViewControllerSwiperView *view = (CCViewControllerSwiperView *)self.view;
    view.currentViewIndex = currentViewController;
}

@end
