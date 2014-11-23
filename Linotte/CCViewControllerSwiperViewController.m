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
}

- (instancetype)initWithViewControllers:(NSArray *)viewControllers
{
    self = [super init];
    if (self) {
        _viewControllers = viewControllers;
    }
    return self;
}

- (void)loadView
{
    NSArray *viewControllerViews = [_viewControllers valueForKeyPath:@"@unionOfObjects.view"];
    CCViewControllerSwiperView *view = [[CCViewControllerSwiperView alloc] initWithViewControllerViews:viewControllerViews];
    view.delegate = self;
    self.view = view;
}

@end
