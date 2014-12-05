//
//  CCOutputViewControllersTransition.m
//  Linotte
//
//  Created by stant on 02/12/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCOutputViewControllersTransition.h"

@implementation CCOutputViewControllersTransition

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    if (self.reversed)
        return 0.3;
    return 0.6;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    if (self.reversed)
        [self reverseTransition:transitionContext];
    else
        [self normalTransition:transitionContext];
}

- (void)normalTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    UINavigationController *navigationController = toViewController.navigationController;
    CGRect navigationBarBounds = navigationController.navigationBar.bounds;
    CGRect statusBarBounds = [UIApplication sharedApplication].statusBarFrame;
    CGFloat yOffset = navigationBarBounds.size.height + statusBarBounds.size.height;
    
    [[transitionContext containerView] addSubview:toViewController.view];
    
    CGRect initialToViewControllerFrame = screenBounds;
    initialToViewControllerFrame.origin.y += fromViewController.view.frame.size.height;
    initialToViewControllerFrame.size.height -= yOffset;
    
    CGRect endToViewControllerFrame = initialToViewControllerFrame;
    endToViewControllerFrame.origin.y = yOffset;
    
    toViewController.view.frame = initialToViewControllerFrame;
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:0 animations:^{
        toViewController.view.frame = endToViewControllerFrame;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

- (void)reverseTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    [[transitionContext containerView] insertSubview:toViewController.view belowSubview:fromViewController.view];
    
    CGRect endFromViewControllerFrame = fromViewController.view.frame;
    endFromViewControllerFrame.origin.y += fromViewController.view.frame.size.height;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        fromViewController.view.frame = endFromViewControllerFrame;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

@end
