//
//  CCMainViewController.m
//  Linotte
//
//  Created by stant on 07/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCMainViewController.h"

#import "CCSplashViewController.h"

#import "CCListViewController.h"
#import "CCAddViewController.h"

#import "CCOutputViewController.h"

#import "CCMainView.h"

@interface CCMainViewController ()

@property(nonatomic, strong)CCSplashViewController *splashViewController;

@property(nonatomic, strong)CCListViewController *listViewController;
@property(nonatomic, strong)CCAddViewController *addViewController;

@end

@implementation CCMainViewController

- (void)loadView
{
    CCMainView *view = [CCMainView new];
    self.view = view;
    
    _addViewController = [CCAddViewController new];
    _addViewController.delegate = self;
    
    [self addChildViewController:_addViewController];
    [view setupAddView:_addViewController.view];
    [_addViewController didMoveToParentViewController:self];
    
    _listViewController = [CCListViewController new];
    _listViewController.delegate = self;
    
    [self addChildViewController:_listViewController];
    [view setupListView:_listViewController.view];
    [_listViewController didMoveToParentViewController:self];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
}

- (void)viewDidLoad
{
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

#pragma mark - CCAddViewControllerDelegate

- (void)addressAdded:(CCAddress *)address
{
    [_listViewController addressAdded:address];
    
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

- (void)addressSelected:(CCAddress *)address
{
    CCOutputViewController *outputViewController = [[CCOutputViewController alloc] initWithAddress:address];
    [self.navigationController pushViewController:outputViewController animated:YES];
}

- (void)addressSelected:(CCList *)list
{
    CCOutputViewController *outputViewController = [[CCOutputViewController alloc] initWithAddress:list];
    [self.navigationController pushViewController:outputViewController animated:YES];
}

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
