//
//  CCSettingsViewController.m
//  Linotte
//
//  Created by stant on 19/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCSettingsViewController.h"

#import "CCSettingsView.h"

@implementation CCSettingsViewController

- (void)loadView
{
    [super loadView];
    
    CCSettingsView *view = [CCSettingsView new];
    view.delegate = self;
    self.view = view;
    
    [self loadContentView];
    
    [view setupLayout];
}

- (void)loadContentView {}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - setter methods

- (void)setContentView:(UIView *)contentView
{
    CCSettingsView *view = (CCSettingsView *)self.view;
    [view setupContentView:view];
}

#pragma mark - CCSettingsViewDelegate methods

- (void)closeButtonPressed:(id)sender
{
    
}

@end
