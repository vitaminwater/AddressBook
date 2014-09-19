//
//  CCFirstAddressDisplaySettingsViewController.m
//  Linotte
//
//  Created by stant on 19/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCFirstAddressDisplaySettingsViewController.h"

#import "CCFirstDisplaySettingsView.h"

@implementation CCFirstAddressDisplaySettingsViewController

- (void)loadContentView
{
    CCFirstDisplaySettingsView *view = [CCFirstDisplaySettingsView new];
    view.delegate = self;
    self.contentView = view;
}

#pragma mark - CCFirstAddressDisplaySettingsViewDelegate

- (void)showListSetting
{
    
}

@end
