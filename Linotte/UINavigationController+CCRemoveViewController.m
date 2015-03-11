//
//  UINavigationController+CCRemoveViewController.m
//  Linotte
//
//  Created by stant on 09/03/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import "UINavigationController+CCRemoveViewController.h"

@implementation UINavigationController (CCRemoveViewController)

- (void)removeViewController:(UIViewController *)viewController
{
    NSMutableArray *viewControllers = [self.viewControllers mutableCopy];
    [viewControllers removeObjectIdenticalTo:viewController];
    self.viewControllers = viewControllers;
}

@end
