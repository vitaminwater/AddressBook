//
//  CCRootViewController.m
//  Linotte
//
//  Created by stant on 28/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCRootViewController.h"

#import "CCRootView.h"

#import "CCViewControllerSwiperViewController.h"

#import "CCSplashViewController.h"

#import "CCHomeViewController.h"
#import "CCAddAddressViewController.h"
#import "CCListStoreViewController.h"

#import "CCOutputViewControllersTransition.h"
#import "CCListOutputViewController.h"
#import "CCOutputViewController.h"

@implementation CCRootViewController
{
    CCSplashViewController *_splashViewController;

    CCViewControllerSwiperViewController *_swiperViewController;
    
    CCListStoreViewController *_listStoreViewController;
    CCHomeViewController *_homeViewController;
    CCAddAddressViewController *_addAddressViewController;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backToHome:) name:kCCBackToHomeNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView
{
    _listStoreViewController = [CCListStoreViewController new];
    _listStoreViewController.delegate = self;
    _homeViewController = [CCHomeViewController new];
    //_homeViewController.delegate = self;
    _addAddressViewController = [CCAddAddressViewController new];
    _addAddressViewController.delegate = self;
    
    _swiperViewController = [[CCViewControllerSwiperViewController alloc] initWithViewControllers:@[_listStoreViewController, _homeViewController, _addAddressViewController] edgeOnly:NO startViewControllerIndex:1];
    _swiperViewController.delegate = self;
    
    [self addChildViewController:_swiperViewController];
    CCRootView *view = [[CCRootView alloc] initWithSwiperView:_swiperViewController.view];
    view.delegate = self;
    self.view = view;
    [_swiperViewController didMoveToParentViewController:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    /*_splashViewController = [CCSplashViewController new];
    _splashViewController.delegate = self;
    
    [self addChildViewController:_splashViewController];
    _splashViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _splashViewController.view.frame = self.view.bounds;
    [self.view addSubview:_splashViewController.view];
    [_splashViewController didMoveToParentViewController:self];*/
    
    self.navigationController.delegate = self;
}

#pragma mark - CCRootViewDelegate methods

- (void)tabBarItemSelectedAtIndex:(NSUInteger)index
{
    [_swiperViewController setCurrentViewControllerIndex:index];
}

#pragma mark - CCSplashViewControllerDelegate methods

- (void)splashFinish
{
    [UIView animateWithDuration:0.2 animations:^{
        _splashViewController.view.alpha = 0;
    } completion:^(BOOL finished) {
        [_splashViewController willMoveToParentViewController:nil];
        [_splashViewController.view removeFromSuperview];
        [_splashViewController removeFromParentViewController];
    }];
}

#pragma mark - UINavigationControllerDelegate methods

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if ([fromVC isKindOfClass:[CCListOutputViewController class]] || [toVC isKindOfClass:[CCListOutputViewController class]]
        || [fromVC isKindOfClass:[CCOutputViewController class]] || [toVC isKindOfClass:[CCOutputViewController class]]) {
        CCOutputViewControllersTransition *transition = [CCOutputViewControllersTransition new];
        transition.reversed = operation == UINavigationControllerOperationPop;
        return transition;
    }
    return nil;
}

#pragma mark - CCViewControllerSwiperViewControllerDelegate methods

- (void)viewControllerShown:(UIViewController *)viewController
{
    CCRootView *view = (CCRootView *)self.view;
    NSUInteger index = [_swiperViewController.viewControllers indexOfObject:viewController];
    [view setSelectedTabItem:index];
    [(UIViewController<CCChildRootViewControllerProtocol> *)viewController viewWillShow];
}

- (void)viewControllerHidden:(UIViewController *)viewController
{
    [(UIViewController<CCChildRootViewControllerProtocol> *)viewController viewWillHide];
}

#pragma mark - NSNotificationCenter target methods

- (void)backToHome:(NSNotification *)note
{
    CCRootView *view = (CCRootView *)self.view;
    [_swiperViewController setCurrentViewControllerIndex:1];
    [view setSelectedTabItem:1];
}

@end
