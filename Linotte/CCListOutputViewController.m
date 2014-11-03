//
//  CCListOutputViewController.m
//  Linotte
//
//  Created by stant on 10/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListOutputViewController.h"

#import "CCCoreDataStack.h"

#import <HexColors/HexColor.h>

#import "CCAlertView.h"
#import "CCActionResultHUD.h"

#import "UIView+CCShowSettingsView.h"

#import "CCModelChangeMonitor.h"
#import "CCModelHelper.h"

#import "CCListOutputListEmptyView.h"

#import "CCListOutputView.h"

#import "CCListViewController.h"
#import "CCAddAddressViewController.h"

#import "CCListOutputListViewModel.h"
#import "CCListViewContentProvider.h"

#import "CCListOutputSettingsViewController.h"
#import "CCListOutputAddressListViewController.h"
#import "CCOutputViewController.h"

#import "CCList.h"
#import "CCAddress.h"


@implementation CCListOutputViewController
{
    CCList *_list;
    
    UIButton *_settingsButton;
    
    CCListViewController *_listViewController;
    CCAddAddressViewController *_addViewController;
    
    CCListOutputAddressListViewController *_listOutputAddressListViewController;
}

- (instancetype)initWithList:(CCList *)list
{
    self = [super init];
    if (self) {
        _list = list;
    }
    return self;
}

- (void)loadView
{
    CCListOutputView *view = [CCListOutputView new];
    view.delegate = self;
    self.view = view;
    
    [view setNotificationEnabled:_list.notifyValue];
    
    if (_list.ownedValue) {
        _addViewController = [CCAddAddressViewController new];
        _addViewController.delegate = self;
        [self addChildViewController:_addViewController];
        [view setupAddView:_addViewController.view];
        [_addViewController didMoveToParentViewController:self];
    }
    
    CCListOutputListViewModel *listModel = [[CCListOutputListViewModel alloc] initWithList:_list];
    CCListViewContentProvider *listProvider = [[CCListViewContentProvider alloc] initWithModel:listModel];
    _listViewController = [[CCListViewController alloc] initWithProvider:listProvider];
    _listViewController.delegate = self;
    _listViewController.deletableItems = _list.ownedValue;
    [self addChildViewController:_listViewController];
    [view setupListView:(CCListView *)_listViewController.view];
    [_listViewController didMoveToParentViewController:self];
    
    [view setListIconImage:[UIImage imageNamed:@"list_pin_neutral"]];
    [view setListInfosText:_list.name];

    [view setupLayout];
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    
    [self.view showSettingsView:listOutputSettingsViewController.view];
    
    [listOutputSettingsViewController didMoveToParentViewController:self];
    
    _settingsButton.enabled = NO;
}

#pragma mark - CCListOutputViewDelegate methods

- (void)notificationEnabled:(BOOL)enabled
{
    _list.notify = @(enabled);
    [[CCCoreDataStack sharedInstance] saveContext];
    [[CCModelChangeMonitor sharedInstance] listDidUpdate:_list fromNetwork:NO];
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

#pragma mark - CCAddAddressViewControllerDelegate

- (void)preSaveAddress:(CCAddress *)address
{
    [address addListsObject:_list];
}

- (void)postSaveAddress:(CCAddress *)address
{
    CCOutputViewController *outputViewController = [[CCOutputViewController alloc] initWithAddress:address addressIsNew:YES];
    [self.navigationController pushViewController:outputViewController animated:YES];
}

- (void)expandAddView
{
    CCListOutputView *view = (CCListOutputView *)self.view;
    view.addViewExpanded = YES;
}

- (void)reduceAddView
{
    CCListOutputView *view = (CCListOutputView *)self.view;
    view.addViewExpanded = NO;
}

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
    [CCActionResultHUD showActionResultWithImage:[UIImage imageNamed:@"completed"] text:NSLocalizedString(@"NOTIF_ADDRESS_DELETE_CONFIRM", @"") delay:1];
    
    [CCAlertView closeAlertView:sender];
}

- (void)alertViewDidSayNo:(CCAlertView *)sender
{
    [CCAlertView closeAlertView:sender];
}

@end
