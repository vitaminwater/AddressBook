//
//  CCListOutputExpandedSettingsViewController.m
//  Linotte
//
//  Created by stant on 28/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListListExpandedSettingsViewController.h"

#import "CCListListExpandedSettingsView.h"

@implementation CCListListExpandedSettingsViewController

- (void)loadContentView
{
    CCListListExpandedSettingsView *view = [CCListListExpandedSettingsView new];
    view.delegate = self;
    self.contentView = view;
}

#pragma mark CCListListExpandedSettingsViewDelegate methods

@end
