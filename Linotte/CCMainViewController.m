//
//  CCMainViewController.m
//  Linotte
//
//  Created by stant on 07/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCMainViewController.h"

#import "CCListViewController.h"
#import "CCAddViewController.h"

#import "CCMainView.h"

@interface CCMainViewController ()

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
}

- (void)expandAddView
{
    ((CCMainView *)self.view).addViewExpanded = YES;
}

- (void)reduceAddView
{
    ((CCMainView *)self.view).addViewExpanded = NO;
}

@end
