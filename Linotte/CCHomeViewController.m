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

#import "CCSwapperViewController.h"

#import "CCAlertView.h"
#import "CCActionResultHUD.h"

#import "CCAnimationDelegator.h"

#import "CCListStoreViewController.h"

#import "CCBookAndNotifiedListViewModel.h"
#import "CCAddressListViewModel.h"
#import "CCListListViewModel.h"
#import "CCLastNotificationModel.h"

#import "CCListViewContentProvider.h"
#import "CCLastNotifListViewContentProvider.h"

#import "CCListViewController.h"

#import "CCAddAddressViewController.h"

#import "CCOutputViewController.h"
#import "CCListOutputViewController.h"

#import "CCHomeListEmptyView.h"

#import "CCHomeView.h"

#import "CCAddress.h"
#import "CCList.h"

@implementation CCHomeViewController
{
    CCSwapperViewController *_swapViewController;
    
    NSArray *_listViewControllers;
    
    CCAnimationDelegator *_animationDelegator;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAddressesPanel:) name:kCCShowAddressesPanelNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showBooksPanel:) name:kCCShowBookPanelNotification object:nil];
    }
    return self;
}

// TODO check location enabled
- (void)loadView
{
    self.title = NSLocalizedString(@"HOME_SCREEN_NAME", @"");
    
    _animationDelegator = [CCAnimationDelegator new];
    
    CCAddressListViewModel *addressListModel = [CCAddressListViewModel new];
    CCListListViewModel *listListModel = [CCListListViewModel new];
    CCLastNotificationModel *lastNotificationModel = [CCLastNotificationModel new];
    _listViewControllers = @[
                                 [self createListViewControllerWithModel:addressListModel orderByLastNotif:NO],
                                 [self createListViewControllerWithModel:listListModel orderByLastNotif:NO],
                                 [self createListViewControllerWithModel:lastNotificationModel orderByLastNotif:YES],
                                 ];
    _swapViewController = [[CCSwapperViewController alloc] initWithFirstViewController:_listViewControllers[0]];
    
    [self addChildViewController:_swapViewController];
    CCHomeView *view = [[CCHomeView alloc] initWithListView:_swapViewController.view animationDelegator:_animationDelegator];
    view.delegate = self;
    self.view = view;
    [_swapViewController didMoveToParentViewController:self];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
}

- (CCListViewController *)createListViewControllerWithModel:(id<CCListViewModelProtocol>)listViewModel orderByLastNotif:(BOOL)orderByLastNotif
{
    CCListViewContentProvider *listProvider;
    
    if (orderByLastNotif)
        listProvider = [[CCLastNotifListViewContentProvider alloc] initWithModel:listViewModel];
    else
        listProvider = [[CCListViewContentProvider alloc] initWithModel:listViewModel];
    
    CCListViewController *listViewController = [[CCListViewController alloc] initWithProvider:listProvider];
    listViewController.animatorDelegator = _animationDelegator;
    listViewController.delegate = self;
    
    return listViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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

#pragma mark - CCChildRootViewControllerProtocol methods

- (void)viewWillShow
{
}

- (void)viewWillHide
{
    CCHomeView *view = (CCHomeView *)self.view;
    [view searchFieldResignFirstResponder];
}

#pragma mark - CCHomeViewDelegate methods

- (void)homePanelSelected:(CCHomeViewPanel)viewPanel
{
    [_swapViewController swapToViewController:_listViewControllers[viewPanel]];
}

- (void)filterList:(NSString *)filterText
{
    for (CCListViewController *listViewController in _listViewControllers) {
        [listViewController filterList:filterText];
    }
}

#pragma mark - CCListViewControllerDelegate methods

- (UIView *)getEmptyView
{
    return [CCHomeListEmptyView new];
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

#pragma marl - NSNotificationCenter target methods

- (void)showAddressesPanel:(NSNotification *)notification
{
    CCHomeView *view = (CCHomeView *)self.view;
    [_swapViewController swapToViewController:_listViewControllers[0]];
    [view setSelectedButtonAtIndex:0];
}

- (void)showBooksPanel:(NSNotification *)notification
{
    CCHomeView *view = (CCHomeView *)self.view;
    [_swapViewController swapToViewController:_listViewControllers[1]];
    [view setSelectedButtonAtIndex:1];
}

@end
