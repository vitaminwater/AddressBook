//
//  CCListStoreNavigationController.m
//  Linotte
//
//  Created by stant on 04/01/15.
//  Copyright (c) 2015 CCSAS. All rights reserved.
//

#import "CCListStoreNavigationController.h"

#import "CCListStoreHomeViewController.h"

@implementation CCListStoreNavigationController

- (instancetype)init
{
    self = [super initWithRootViewController:[CCListStoreHomeViewController new]];
    if (self) {
    }
    return self;
}

- (void)viewWillShow
{
    
}

- (void)viewWillHide
{
    
}

@end
