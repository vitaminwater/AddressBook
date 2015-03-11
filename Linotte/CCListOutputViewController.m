//
//  CCListOutputViewController.m
//  Linotte
//
//  Created by stant on 10/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListOutputViewController.h"

#import "CCLinotteCoreDataStack.h"
#import "CCLinotteEngineCoordinator.h"
#import "CCSynchronizationHandler.h"
#import "CCModelChangeMonitor.h"
#import "CCModelHelper.h"

#import <HexColors/HexColor.h>

#import "CCAlertView.h"
#import "CCActionResultHUD.h"

#import "UIView+CCShowSettingsView.h"

#import "CCListOutputListEmptyView.h"

#import "CCListOutputView.h"

#import "CCAnimationDelegator.h"

#import "CCListViewController.h"
#import "CCFirstListDisplaySettingsViewController.h"

#import "CCListOutputListViewModel.h"
#import "CCListViewContentProvider.h"

#import "CCSearchViewController.h"
#import "CCListOutputSettingsViewController.h"
#import "CCListOutputAddressListViewController.h"
#import "CCOutputViewController.h"

#import "CCList.h"
#import "CCAddress.h"


@implementation CCListOutputViewController
{
    BOOL _listIsNew;
    CCList *_list;
    
    UIButton *_settingsButton;
    
    CCListViewController *_listViewController;
    CCSearchViewController *_searchViewController;
    
    CCListOutputAddressListViewController *_listOutputAddressListViewController;
}

- (instancetype)initWithList:(CCList *)list listIsNew:(BOOL)listIsNew
{
    self = [self initWithList:list];
    if (self) {
        _listIsNew = listIsNew;
        [[CCModelChangeMonitor sharedInstance] addDelegate:self];
    }
    return self;
}

- (instancetype)initWithList:(CCList *)list
{
    self = [super init];
    if (self) {
        _list = list;
        [[CCModelChangeMonitor sharedInstance] addDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [[CCModelChangeMonitor sharedInstance] removeDelegate:self];
}

- (void)loadView
{
    CCListOutputView *view = [CCListOutputView new];
    view.delegate = self;
    self.view = view;
    
    [view setNotificationEnabled:_list.notifyValue];
    
    CCAnimationDelegator *animationDelegator = [CCAnimationDelegator new];
    CCListOutputListViewModel *listModel = [[CCListOutputListViewModel alloc] initWithList:_list];
    CCListViewContentProvider *listProvider = [[CCListViewContentProvider alloc] initWithModel:listModel];
    _listViewController = [[CCListViewController alloc] initWithProvider:listProvider];
    _listViewController.animatorDelegator = animationDelegator;
    _listViewController.delegate = self;
    _listViewController.deletableItems = _list.ownedValue;
    [self addChildViewController:_listViewController];
    [view setupListView:(CCListView *)_listViewController.view];
    [_listViewController didMoveToParentViewController:self];
    
    [self updateListInfos];
    
    if (_listIsNew) {
        CCFirstListDisplaySettingsViewController *firstAddressDisplaySettingsViewController = [[CCFirstListDisplaySettingsViewController alloc] initWithList:_list];
        firstAddressDisplaySettingsViewController.delegate = self;
        [self addChildViewController:firstAddressDisplaySettingsViewController];
        
        [self.view showSettingsView:firstAddressDisplaySettingsViewController.view fullScreen:NO];
        
        [firstAddressDisplaySettingsViewController didMoveToParentViewController:self];
    }

    [view setupLayout];
}

- (void)updateListInfos {
    CCListOutputView *view = (CCListOutputView *)self.view;
    [view loadListIconWithUrl:_list.icon];
    [view setListInfosText:_list.name];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = _list.name;
    
    NSString *color = @"#6b6b6b";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithHexString:color], NSFontAttributeName: [UIFont fontWithName:@"Montserrat-Bold" size:23]};
    
    { // left bar button items
        CGRect backButtonFrame = CGRectMake(0, 0, 30, 30);
        UIButton *backButton = [UIButton new];
        [backButton setImage:[UIImage imageNamed:@"back_icon.png"] forState:UIControlStateNormal];
        backButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        backButton.frame = backButtonFrame;
        [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        
        UIBarButtonItem *emptyBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        emptyBarButtonItem.width = -10;
        self.navigationItem.leftBarButtonItems = @[emptyBarButtonItem, barButtonItem];
    }
    
    if (_list.ownedValue) {
        { // right bar button items
            CGRect settingsButtonFrame = CGRectMake(0, 0, 30, 30);
            _settingsButton = [UIButton new];
            [_settingsButton setImage:[UIImage imageNamed:@"settings_icon.png"] forState:UIControlStateNormal];
            _settingsButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
            _settingsButton.frame = settingsButtonFrame;
            [_settingsButton addTarget:self action:@selector(settingsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_settingsButton];
            
            self.navigationItem.rightBarButtonItems = @[barButtonItem];
        }
    }
    
    self.navigationItem.hidesBackButton = YES;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    [CCLEC forceListSynchronization:_list];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)showSearchViewControllerIfNotPresent
{
    if (_searchViewController != nil)
        return;
    _searchViewController = [[CCSearchViewController alloc] initWithList:_list];
    _searchViewController.delegate = self;
    
    CCListOutputView *view = (CCListOutputView *)self.view;
    [self addChildViewController:_searchViewController];
    [view presentSearchViewControllerView:_searchViewController.view];
    [_searchViewController didMoveToParentViewController:self];
}

- (void)hideSearchViewControllerIfPresent
{
    if (_searchViewController == nil)
        return;
    
    CCListOutputView *view = (CCListOutputView *)self.view;
    [_searchViewController willMoveToParentViewController:nil];
    [view dismissSearchViewControllerView];
    [_searchViewController removeFromParentViewController];
    _searchViewController = nil;
}

#pragma mark - UIBarButtons target methods

- (void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)settingsButtonPressed:(id)sender
{
    CCListOutputSettingsViewController *listOutputSettingsViewController = [CCListOutputSettingsViewController new];
    listOutputSettingsViewController.delegate = self;
    [self addChildViewController:listOutputSettingsViewController];
    
    [self.view showSettingsView:listOutputSettingsViewController.view fullScreen:NO];
    
    [listOutputSettingsViewController didMoveToParentViewController:self];
    
    _settingsButton.enabled = NO;
}

#pragma mark - CCListOutputViewDelegate methods

- (void)notificationEnabled:(BOOL)enabled
{
    [[CCModelChangeMonitor sharedInstance] listsWillUpdateUserData:@[_list] send:YES];
    _list.notify = @(enabled);
    [[CCLinotteCoreDataStack sharedInstance] saveContext];
    [[CCModelChangeMonitor sharedInstance] listsDidUpdateUserData:@[_list] send:YES];
}

- (void)filterList:(NSString *)filterText
{
    [self showSearchViewControllerIfNotPresent];
    [_searchViewController updateSearchString:filterText];
}

#pragma mark - CCSearchViewControllerDelegate methods

- (void)closeSearchViewController
{
    CCListOutputView *view = (CCListOutputView *)self.view;
    [view searchFieldResignFirstResponder];
    [self hideSearchViewControllerIfPresent];
}

#pragma mark - CCListOutputListEmptyViewDelegate methods

- (void)showAddressList
{
    _listOutputAddressListViewController = [[CCListOutputAddressListViewController alloc] initWithList:_list];
    [self.navigationController pushViewController:_listOutputAddressListViewController animated:YES];
}

#pragma mark - CCListViewControllerDelegate methods

- (UIView *)getEmptyView
{
    if (_list.ownedValue == NO)
        return nil;
    CCListOutputListEmptyView *emptyView = [CCListOutputListEmptyView new];
    emptyView.delegate = self;
    return emptyView;
}

- (void)addressSelected:(CCAddress *)address
{
    CCOutputViewController *outputViewController = [[CCOutputViewController alloc] initWithAddress:address];
    outputViewController.delegate = self;
    [self.navigationController pushViewController:outputViewController animated:YES];
}

- (void)listSelected:(CCList *)list {}

- (void)deleteAddress:(CCAddress *)address
{
    NSString *alertTitle = NSLocalizedString(@"NOTIF_ADDRESS_DELETE", @"");
    
    CCAlertView *alertView = [CCAlertView showAlertViewWithText:alertTitle target:self leftAction:@selector(alertViewDidSayYes:) rightAction:@selector(alertViewDidSayNo:)];
    alertView.userInfo = address;
}

- (void)deleteList:(CCList *)list {}

//#pragma mark - CCAddAddressViewControllerDelegate
//
//- (void)addAddressViewController:(id)sender preSaveAddress:(CCAddress *)address
//{
//    [[CCModelChangeMonitor sharedInstance] addresses:@[address] willMoveToList:_list send:YES];
//    [_list addAddressesObject:address];
//    [[CCLinotteCoreDataStack sharedInstance] saveContext];
//    [[CCModelChangeMonitor sharedInstance] addresses:@[address] didMoveToList:_list send:YES];
//}
//
//- (void)addAddressViewController:(id)sender postSaveAddress:(CCAddress *)address
//{
//    CCOutputViewController *outputViewController = [[CCOutputViewController alloc] initWithAddress:address addressIsNew:YES];
//    [self.navigationController pushViewController:outputViewController animated:YES];
//}

#pragma mark - CCSettingsViewControllerDelegate methods

- (void)settingsViewControllerDidEnd:(UIViewController *)sender
{
    [sender willMoveToParentViewController:nil];
    [self.view hideSettingsView:sender.view];
    [sender removeFromParentViewController];
    
    if ([sender isKindOfClass:[CCListOutputSettingsViewController class]])
        _settingsButton.enabled = YES;
}

#pragma mark - CCAlertView target methods

- (void)alertViewDidSayYes:(CCAlertView *)sender
{
    [CCModelHelper deleteAddress:sender.userInfo];
    [CCActionResultHUD showActionResultWithImage:[UIImage imageNamed:@"completed"] inView:self.view text:NSLocalizedString(@"NOTIF_ADDRESS_DELETE_CONFIRM", @"") delay:1];
    
    [CCAlertView closeAlertView:sender];
}

- (void)alertViewDidSayNo:(CCAlertView *)sender
{
    [CCAlertView closeAlertView:sender];
}

#pragma mark CCModelChangeMonitorDelegate -

- (void)listsDidUpdate:(NSArray *)lists send:(BOOL)send
{
    if ([lists containsObject:_list]) {
        [self updateListInfos];
    }
}

@end
