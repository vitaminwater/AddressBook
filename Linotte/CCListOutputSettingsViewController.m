//
//  CCListOutputExpandedSettingsViewController.m
//  Linotte
//
//  Created by stant on 28/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListOutputSettingsViewController.h"

#import "CCListOutputSettingsView.h"

@implementation CCListOutputSettingsViewController

- (void)loadContentView
{
    CCListOutputSettingsView *view = [CCListOutputSettingsView new];
    view.delegate = self;
    self.contentView = view;
}

#pragma mark - CCListOutputSettingsViewDelegate methods

#pragma mark CCListOutputListEmptyViewDelegate methods

- (void)showAddressList
{
    [self.delegate showAddressList];
}

@end
