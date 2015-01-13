//
//  CCRootViewController.m
//  Linotte
//
//  Created by stant on 28/11/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCRootViewController.h"

#import <MessageUI/MessageUI.h>

#import "CCLinotteBrowserViewController.h"

#import "CCRootView.h"

#import "CCActionResultHUD.h"

#import "CCViewControllerSwiperViewController.h"

#import "CCSplashViewController.h"

#import "CCHomeViewController.h"
#import "CCAddAddressViewController.h"
#import "CCListStoreNavigationController.h"

#import "CCOutputViewControllersTransition.h"
#import "CCListOutputViewController.h"
#import "CCOutputViewController.h"

@implementation CCRootViewController
{
    CCSplashViewController *_splashViewController;

    CCViewControllerSwiperViewController *_swiperViewController;
    
    CCListStoreNavigationController *_listStoreNavigationController;
    CCHomeViewController *_homeViewController;
    CCAddAddressViewController *_addAddressViewController;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backToHome:) name:kCCBackToHomeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNotificationPanel:) name:kCCShowNotificationPanelNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showListOutput:) name:kCCShowListOutputNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showBrowser:) name:kCCShowBrowserNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showEmail:) name:kCCShowEmailNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView
{
    _listStoreNavigationController = [CCListStoreNavigationController new];
    _homeViewController = [CCHomeViewController new];
    _addAddressViewController = [CCAddAddressViewController new];
    
    _swiperViewController = [[CCViewControllerSwiperViewController alloc] initWithViewControllers:@[_listStoreNavigationController, _homeViewController, _addAddressViewController] edgeOnly:NO startViewControllerIndex:1];
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

- (void)showNotificationPanel:(NSNotification *)note
{
    CCRootView *view = (CCRootView *)self.view;
    [_swiperViewController setCurrentViewControllerIndex:2];
    [view setSelectedTabItem:2];
}

- (void)showListOutput:(NSNotification *)note
{
    CCList *list = [note object];
    
    CCListOutputViewController *listOutputViewController = [[CCListOutputViewController alloc] initWithList:list listIsNew:YES];
    [self.navigationController pushViewController:listOutputViewController animated:YES];
}

- (void)showBrowser:(NSNotification *)note
{
    NSString *rootUrl = [note object];
    
    CCLinotteBrowserViewController *browserViewController = [[CCLinotteBrowserViewController alloc] initWithRootUrl:rootUrl];
    [self presentViewController:browserViewController animated:YES completion:^{}];
}

- (void)showEmail:(NSNotification *)note
{
    NSDictionary *emailInfos = [note object];
    
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailComposerViewController = [[MFMailComposeViewController alloc] init];
        [mailComposerViewController setToRecipients:@[emailInfos[@"email"]]];
        [self presentViewController:mailComposerViewController animated:YES completion:^{}];
    }
    else
    {
        [CCActionResultHUD showActionResultWithImage:[UIImage imageNamed:@"sad_icon"] inView:[CCActionResultHUD applicationRootView] text:NSLocalizedString(@"CANNOT_SEND_MAIL", @"") delay:3];
    }
}

@end
