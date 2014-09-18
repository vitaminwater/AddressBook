//
//  CCListListViewController.m
//  Linotte
//
//  Created by stant on 13/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListListViewController.h"

#import <HexColors/HexColor.h>

#import "CCListViewContentProvider.h"
#import "CCListListViewModel.h"

#import "CCAddListViewController.h"
#import "CCListViewController.h"

#import "CCListListView.h"

@interface CCListListViewController()

@property(nonatomic, strong)CCAddListViewController *addListViewController;
@property(nonatomic, strong)CCListViewController *listViewController;

@end

@implementation CCListListViewController

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)loadView
{
    CCListListView *view = [CCListListView new];
    view.delegate = self;
    self.view = view;
    
    _addListViewController = [CCAddListViewController new];
    _addListViewController.delegate = self;
    [self addChildViewController:_addListViewController];
    [view setupAddListView:_addListViewController.view];
    [_addListViewController didMoveToParentViewController:self];
    
    CCListListViewModel *listModel = [CCListListViewModel new];
    CCListViewContentProvider *listProvider = [[CCListViewContentProvider alloc] initWithModel:listModel];
    _listViewController = [[CCListViewController alloc] initWithProvider:listProvider];
    _listViewController.delegate = self;
    [self addChildViewController:_listViewController];
    [view setupListView:_listViewController.view];
    [_listViewController didMoveToParentViewController:self];
    
    [view setupLayout];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"MY_BOOKS", @"");
    
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
    self.navigationItem.hidesBackButton = YES;
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

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

#pragma mark - UIBarButtons target methods

- (void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - CCListListViewDelegate methods

#pragma mark - CCAddListViewControllerDelegate methods

- (void)listCreated:(CCList *)list
{
    [_listViewController.provider.model addList:list];
    [_delegate listCreated:list];
}

#pragma mark - CCListViewControllerDelegate methods

- (void)showOptionView {}

- (void)hideOptionView {}

- (void)addressSelected:(CCAddress *)address {}

- (void)listSelected:(CCList *)list
{
    
}

@end
