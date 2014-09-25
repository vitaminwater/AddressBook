//
//  CCListOutputAddressListViewController.m
//  Linotte
//
//  Created by stant on 25/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListOutputAddressListViewController.h"

#import "CCListOutputAddressListView.h"

@implementation CCListOutputAddressListViewController

- (void)loadView
{
    CCListOutputAddressListView *view = [CCListOutputAddressListView new];
    view.delegate = self;
    self.view = view;
}

#pragma mark CCListOutputAddressListViewDelegate methods

@end
