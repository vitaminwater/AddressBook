//
//  CCListOutputViewController.m
//  Linotte
//
//  Created by stant on 10/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListOutputViewController.h"

#import <HexColors/HexColor.h>
#import <RestKit/RestKit.h>

#import "CCListOutputView.h"

#import "CCListViewController.h"
#import "CCAddAddressViewController.h"

#import "CCListOutputListViewModel.h"
#import "CCListViewContentProvider.h"

#import "CCAddressSettingsViewController.h"

#import "CCList.h"
#import "CCAddress.h"

@interface CCListOutputViewController ()

@property(nonatomic, strong)CCList *list;

@property(nonatomic, strong)CCListViewController *listViewController;
@property(nonatomic, strong)CCAddAddressViewController *addViewController;

@end

@implementation CCListOutputViewController

- (id)initWithList:(CCList *)list
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
    
    _addViewController = [CCAddAddressViewController new];
    _addViewController.delegate = self;
    [self addChildViewController:_addViewController];
    [view setupAddView:_addViewController.view];
    [_addViewController didMoveToParentViewController:self];
    
    CCListOutputListViewModel *listModel = [[CCListOutputListViewModel alloc] initWithList:_list];
    CCListViewContentProvider *listProvider = [[CCListViewContentProvider alloc] initWithModel:listModel];
    _listViewController = [[CCListViewController alloc] initWithProvider:listProvider];
    _listViewController.delegate = self;
    [self addChildViewController:_listViewController];
    [view setupListView:_listViewController.view];
    [_listViewController didMoveToParentViewController:self];
    
    [view setListIconImage:[UIImage imageNamed:@"list_pin_neutral"]];
    [view setListInfosText:@"pouet"];

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
    
    { // right bar button items
        CGRect settingsButtonFrame = CGRectMake(0, 0, 30, 30);
        UIButton *settingsButton = [UIButton new];
        [settingsButton setImage:[UIImage imageNamed:@"settings_icon.png"] forState:UIControlStateNormal];
        settingsButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        settingsButton.frame = settingsButtonFrame;
        [settingsButton addTarget:self action:@selector(settingsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingsButton];
        
        self.navigationItem.rightBarButtonItems = @[barButtonItem];
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
    
}

#pragma mark - CCListViewControllerDelegate methods

- (void)showOptionView
{
    
}

- (void)hideOptionView
{
    
}

- (void)addressSelected:(CCAddress *)address
{
    
}

- (void)listSelected:(CCList *)list
{
    
}

#pragma mark - CCAddAddressViewControllerDelegate

- (void)preSaveAddress:(CCAddress *)address
{
    [address addListsObject:_list];
}

- (void)postSaveAddress:(CCAddress *)address
{
    
}

- (void)expandAddView
{
    
}

- (void)reduceAddView
{
    
}

@end
