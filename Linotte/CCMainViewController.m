//
//  CCMainViewController.m
//  Linotte
//
//  Created by stant on 07/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCMainViewController.h"

#import "CCSplashViewController.h"

#import "CCListListViewController.h"
#import "CCListStoreViewController.h"

#import "CCHomeListViewModel.h"
#import "CCListViewContentProvider.h"

#import "CCListViewController.h"
#import "CCAddAddressViewController.h"

#import "CCOutputViewController.h"
#import "CCListOutputViewController.h"

#import "CCMainListEmptyView.h"

#import "CCMainView.h"

@interface CCMainViewController ()

@property(nonatomic, strong)CCSplashViewController *splashViewController;

@property(nonatomic, strong)CCListViewController *listViewController;
@property(nonatomic, strong)CCAddAddressViewController *addViewController;

@end

@implementation CCMainViewController

// TODO check location enabled
- (void)loadView
{
    CCMainView *view = [CCMainView new];
    view.delegate = self;
    self.view = view;
    
    _addViewController = [CCAddAddressViewController new];
    _addViewController.delegate = self;
    [self addChildViewController:_addViewController];
    [view setupAddView:_addViewController.view];
    [_addViewController didMoveToParentViewController:self];
    
    CCHomeListViewModel *listModel = [CCHomeListViewModel new];
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

#pragma mark - CCMainViewDelegate methods

- (void)showListStore
{
    CCListStoreViewController *listStoreViewController = [CCListStoreViewController new];
    listStoreViewController.delegate = self;
    [self.navigationController pushViewController:listStoreViewController animated:YES];
}

- (void)showListList
{
    CCListListViewController *listListViewController = [CCListListViewController new];
    listListViewController.delegate = self;
    [self.navigationController pushViewController:listListViewController animated:YES];
}

#pragma mark - CCAddAddressViewControllerDelegate methods

- (void)preSaveAddress:(CCAddress *)address
{
    
}

- (void)postSaveAddress:(CCAddress *)address
{
    CCOutputViewController *outputViewController = [[CCOutputViewController alloc] initWithAddress:address addressIsNew:YES];
    [self.navigationController pushViewController:outputViewController animated:YES];
}

- (void)expandAddView
{
    ((CCMainView *)self.view).addViewExpanded = YES;
}

- (void)reduceAddView
{
    ((CCMainView *)self.view).addViewExpanded = NO;
}

#pragma mark - CCListViewControllerDelegate methods

- (void)showOptionViewProgress:(CGFloat)pixels
{
    
}

- (void)showOptionView
{
    ((CCMainView *)self.view).optionViewExpanded = YES;
}

- (void)hideOptionViewProgress:(CGFloat)pixels
{
    
}

- (void)hideOptionView
{
    ((CCMainView *)self.view).optionViewExpanded = NO;
}

- (UIView *)getEmptyView
{
    return [CCMainListEmptyView new];
}

- (void)addressSelected:(CCAddress *)address
{
    CCOutputViewController *outputViewController = [[CCOutputViewController alloc] initWithAddress:address];
    [self.navigationController pushViewController:outputViewController animated:YES];
}

- (void)listSelected:(CCList *)list
{
    CCListOutputViewController *listOutputViewController = [[CCListOutputViewController alloc] initWithList:list];
    [self.navigationController pushViewController:listOutputViewController animated:YES];
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

@end
