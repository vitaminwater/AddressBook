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
    NSArray *_viewControllers;
    
    BOOL _edgeOnly;
}

- (instancetype)initWithViewControllers:(NSArray *)viewControllers edgeOnly:(BOOL)edgeOnly
{
    self = [super init];
    if (self) {
        _viewControllers = viewControllers;
        _edgeOnly = edgeOnly;
    }
    return self;
}

- (void)loadView
{
    NSArray *viewControllerViews = [_viewControllers valueForKeyPath:@"@unionOfObjects.view"];
    for (UIViewController *viewController in _viewControllers) {
        [self addChildViewController:viewController];
    }
    
    CCViewControllerSwiperView *view = [[CCViewControllerSwiperView alloc] initWithViewControllerViews:viewControllerViews edgeOnly:_edgeOnly];
    view.delegate = self;
    self.view = view;
    
    for (UIViewController *viewController in _viewControllers) {
        [viewController didMoveToParentViewController:self];
    }
}

#pragma mark - CCViewControllerSwiperViewDelegate

- (NSString *)nameForViewControllerAtIndex:(NSUInteger)index
{
    UIViewController *viewController = _viewControllers[index];
    return viewController.title;
}

@end
