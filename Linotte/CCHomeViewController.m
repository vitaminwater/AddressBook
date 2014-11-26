//
//  CCMainViewController.m
//  Linotte
//
//  Created by stant on 07/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCHomeViewController.h"

#import <Mixpanel/Mixpanel.h>

#import "CCCoreDataStack.h"
#import "CCModelChangeMonitor.h"
#import "CCModelHelper.h"

#import "CCViewControllerSwiperViewController.h"

#import "CCAlertView.h"
#import "CCActionResultHUD.h"

#import "CCAnimationDelegator.h"

#import "CCSplashViewController.h"

#import "CCListListViewController.h"
#import "CCListStoreViewController.h"

#import "CCBookAndNotifiedListViewModel.h"
#import "CCAddressListViewModel.h"
#import "CCListListViewModel.h"
#import "CCLastNotificationModel.h"

#import "CCListViewContentProvider.h"
#import "CCLastNotifListViewContentProvider.h"

#import "CCListViewController.h"

#import "CCAllAddAddressViewController.h"

#import "CCOutputViewController.h"
#import "CCListOutputViewController.h"

#import "CCMainListEmptyView.h"

#import "CCHomeView.h"

#import "CCAddress.h"
#import "CCList.h"

@implementation CCHomeViewController
{
    CCSplashViewController *_splashViewController;
    
    CCViewControllerSwiperViewController *_swipeAddAddressesController;
    CCViewControllerSwiperViewController *_swipeListViewController;
    
    CCAnimationDelegator *_animationDelegator;
}

// TODO check location enabled
- (void)loadView
{
    CCHomeView *view = [CCHomeView new];
    view.delegate = self;
    self.view = view;

    _swipeAddAddressesController = [CCAllAddAddressViewController new];
    _swipeAddAddressesController.delegate = self;
    [self addChildViewController:_swipeAddAddressesController];
    [view setupAddView:_swipeAddAddressesController.view];
    [_swipeAddAddressesController didMoveToParentViewController:self];

    _animationDelegator = [CCAnimationDelegator new];
    
    CCAddressListViewModel *addressListModel = [CCAddressListViewModel new];
    CCListListViewModel *listListModel = [CCListListViewModel new];
    CCLastNotificationModel *lastNotificationModel = [CCLastNotificationModel new];
    NSArray *viewControllers = @[
                                 [self createListViewControllerWithModel:addressListModel title:@"My Addresses" orderByLastNotif:NO],
                                 [self createListViewControllerWithModel:listListModel title:@"My Books" orderByLastNotif:NO],
                                 [self createListViewControllerWithModel:lastNotificationModel title:@"Last notifications" orderByLastNotif:YES],
                                 ];
    _swipeListViewController = [[CCViewControllerSwiperViewController alloc] initWithViewControllers:viewControllers edgeOnly:YES];
    
    [self addChildViewController:_swipeListViewController];
    [view setupListView:_swipeListViewController.view animationDelegator:_animationDelegator];
    [_swipeListViewController didMoveToParentViewController:self];
    
    [view setupLayout];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
}

- (CCListViewController *)createListViewControllerWithModel:(id<CCListViewModelProtocol>)listViewModel title:(NSString *)title orderByLastNotif:(BOOL)orderByLastNotif
{
    CCListViewContentProvider *listProvider;
    
    if (orderByLastNotif)
        listProvider = [[CCLastNotifListViewContentProvider alloc] initWithModel:listViewModel];
    else
        listProvider = [[CCListViewContentProvider alloc] initWithModel:listViewModel];
    
    CCListViewController *listViewController = [[CCListViewController alloc] initWithProvider:listProvider];
    listViewController.animatorDelegator = _animationDelegator;
    listViewController.delegate = self;
    
    listViewController.title = title;
    
    return listViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _splashViewController = [CCSplashViewController new];
    _splashViewController.delegate = self;
    
    [self addChildViewController:_splashViewController];
    _splashViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _splashViewController.view.frame = self.view.bounds;
    [self.view addSubview:_splashViewController.view];
    [_splashViewController didMoveToParentViewController:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - CCViewControllerSwiperViewControllerDelegate methods

- (void)viewControllerShown:(UIViewController *)viewController
{
    
}

#pragma mark - CCHomeViewDelegate methods

- (void)showListStore
{
    CCListStoreViewController *listStoreViewController = [CCListStoreViewController new];
    listStoreViewController.delegate = self;
    [self.navigationController pushViewController:listStoreViewController animated:YES];
}

#pragma mark - CCAddAddressViewControllerDelegate methods

- (void)addAddressViewController:(id)sender preSaveAddress:(CCAddress *)address
{
    CCList *list = [CCModelHelper defaultList];
    [[CCModelChangeMonitor sharedInstance] addresses:@[address] willMoveToList:list send:YES];
    [list addAddressesObject:address];
    [[CCCoreDataStack sharedInstance] saveContext];
    [[CCModelChangeMonitor sharedInstance] addresses:@[address] didMoveToList:list send:YES];
}

- (void)addAddressViewController:(id)sender postSaveAddress:(CCAddress *)address
{
    CCOutputViewController *outputViewController = [[CCOutputViewController alloc] initWithAddress:address addressIsNew:YES];
    [self.navigationController pushViewController:outputViewController animated:YES];
}

- (void)addAddressViewControllerExpandAddView:(id)sender
{
    ((CCHomeView *)self.view).addViewExpanded = YES;
}

- (void)addAddressViewControllerReduceAddView:(id)sender
{
    ((CCHomeView *)self.view).addViewExpanded = NO;
}

#pragma mark - CCListViewControllerDelegate methods

- (UIView *)getEmptyView
{
    return [CCMainListEmptyView new];
}

- (void)addressSelected:(CCAddress *)address
{
    CCOutputViewController *outputViewController = [[CCOutputViewController alloc] initWithAddress:address];
    outputViewController.delegate = self;
    [self.navigationController pushViewController:outputViewController animated:YES];
}

- (void)listSelected:(CCList *)list
{
    CCListOutputViewController *listOutputViewController = [[CCListOutputViewController alloc] initWithList:list];
    listOutputViewController.delegate = self;
    [self.navigationController pushViewController:listOutputViewController animated:YES];
}

- (void)deleteAddress:(CCAddress *)address
{
    NSString *alertTitle = NSLocalizedString(@"NOTIF_ADDRESS_DELETE", @"");
    
    CCAlertView *alertView = [CCAlertView showAlertViewWithText:alertTitle target:self leftAction:@selector(alertViewDidSayYesForAddress:) rightAction:@selector(alertViewDidSayNo:)];
    alertView.userInfo = address;
}

- (void)deleteList:(CCList *)list
{
    NSString *alertTitle = NSLocalizedString(@"NOTIF_LIST_DELETE", @"");
    
    CCAlertView *alertView = [CCAlertView showAlertViewWithText:alertTitle target:self leftAction:@selector(alertViewDidSayYesForList:) rightAction:@selector(alertViewDidSayNo:)];
    alertView.userInfo = list;
}

#pragma mark - CCListListViewControllerDelegate

#pragma mark - CCSplashViewControllerDelegate

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

#pragma mark - CCAlertView target methods

- (void)alertViewDidSayYesForAddress:(CCAlertView *)sender
{
    [CCModelHelper deleteAddress:sender.userInfo];
    [CCActionResultHUD showActionResultWithImage:[UIImage imageNamed:@"completed"] text:NSLocalizedString(@"NOTIF_ADDRESS_DELETE_CONFIRM", @"") delay:1];
    
    [CCAlertView closeAlertView:sender];
}

- (void)alertViewDidSayYesForList:(CCAlertView *)sender
{
    [CCModelHelper deleteList:sender.userInfo];
    [CCActionResultHUD showActionResultWithImage:[UIImage imageNamed:@"completed"] text:NSLocalizedString(@"NOTIF_LIST_DELETE_CONFIRM", @"") delay:1];
    
    [CCAlertView closeAlertView:sender];
}

- (void)alertViewDidSayNo:(CCAlertView *)sender
{
    [CCAlertView closeAlertView:sender];
}

@end
